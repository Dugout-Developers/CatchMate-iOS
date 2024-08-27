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
    
    func showToast(message: String, buttonContainerExists: Bool = false, completion: (() -> Void)? = nil) {
        let toastLabel = CMToastMessageLabel(message: message)
        
        // 토스트 메시지의 최대 너비를 설정
        let maxWidth = self.view.frame.width - 32 // 좌우 여백 16씩

        let containerWidth = maxWidth
        let labelSize = toastLabel.sizeThatFits(CGSize(width: maxWidth - 20, height: CGFloat.greatestFiniteMagnitude)) // 20은 레이블 좌우 여백
        let containerHeight = labelSize.height + 24 // 레이블 상하 여백 12씩 추가
        
        // 컨테이너 뷰의 프레임 설정
        let toastContainerView = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight))
        toastContainerView.backgroundColor = .clear
        toastContainerView.addSubview(toastLabel)
        
        // 레이블의 프레임 설정
        toastLabel.frame = CGRect(x: 16, y: 0, width: maxWidth, height: labelSize.height)

        let safeAreaBottom = self.view.safeAreaInsets.bottom
        // 토스트 메시지의 위치 설정
        if buttonContainerExists {
            toastContainerView.frame.origin.y = self.view.frame.height - containerHeight - 72 - safeAreaBottom
        } else {
            toastContainerView.frame.origin.y = self.view.safeAreaInsets.bottom + self.view.frame.height - containerHeight - 12 - safeAreaBottom
        }
        
        // 컨테이너 뷰를 메인 뷰에 추가
        self.view.addSubview(toastContainerView)
        
        // 애니메이션을 통해 1초 후에 사라지게 설정
        UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveEaseOut, animations: {
            toastContainerView.alpha = 0.0
        }) { (_) in
            toastContainerView.removeFromSuperview()
            completion?()
        }
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

