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
}

enum AnchorPosition {
    case top
    case bottom
}
