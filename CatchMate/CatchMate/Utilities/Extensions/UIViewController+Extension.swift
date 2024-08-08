//
//  UIViewController+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 6/15/24.
//

import UIKit
import SnapKit
import FlexLayout
import PinLayout

extension UIViewController {
    
    func showToast(message: String, at position: CGPoint? = nil, anchorPosition: AnchorPosition? = nil) {
        let toastLabel = CMToastMessageLabel(message: message)
        
        // 토스트 메시지 레이블의 크기 설정
        let toastWidth = UIScreen.main.bounds.width - (2 * 16) // 좌우 여백 16포인트씩
        toastLabel.frame = CGRect(x: 16, y: 0, width: toastWidth, height: 40)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        let safeAreaTop = window.safeAreaInsets.top
        toastLabel.frame.origin.y = safeAreaTop + 12
        window.addSubview(toastLabel)
        
        // 1초 동안 표시된 후 사라지도록 애니메이션 적용
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { (isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    /// 알림창 띄우기
    func showAlert(message: String, title: String = "알림", isCancelButton: Bool = false, yesAction: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yes = UIAlertAction(title: "확인", style: .default) { _ in
            yesAction?()
        }
        
        if isCancelButton {
            let cancel = UIAlertAction(title: "취소", style: .destructive, handler: nil)
            alert.addAction(cancel)
        }
        alert.addAction(yes)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - 키보드 올라갈 때 뷰 설정 관련
    // 키보드 노티피케이션 등록
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 키보드 노티피케이션 해제
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 키보드가 나타날 때 호출되는 함수
    @objc private func keyboardWillShow(_ notification: Notification) {
        adjustViewForKeyboard(notification: notification, isShowing: true)
    }
    
    // 키보드가 사라질 때 호출되는 함수
    @objc private func keyboardWillHide(_ notification: Notification) {
        adjustViewForKeyboard(notification: notification, isShowing: false)
    }
    
    // 뷰 위치 조정 함수
    private func adjustViewForKeyboard(notification: Notification, isShowing: Bool) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let changeInHeight = isShowing ? keyboardFrame.height : 0
        
        UIView.animate(withDuration: animationDuration) {
            self.view.frame.origin.y = -changeInHeight
        }
    }
}

enum AnchorPosition {
    case top
    case bottom
}
