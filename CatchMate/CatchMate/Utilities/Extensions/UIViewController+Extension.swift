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
    
    func showToast(message: String, relativeTo view: UIView, using layoutLibrary: LayoutLibrary, anchorPosition: AnchorPosition) {
        let toastLabel = CMToastMessageLabel(message: message)
        let labelWidth = ButtonGridSystem.getGridSystem(totalWidht: Screen.width, startIndex: 1, columnCount: 5).length
        
        // 토스트 메시지 레이블을 뷰에 추가
        self.view.addSubview(toastLabel)
        
        switch layoutLibrary {
        case .flexLayout:
            toastLabel.pin.width(Screen.width - (2*ButtonGridSystem.getMargin()))
            toastLabel.pin.minHeight(40)
            switch anchorPosition {
            case .top:
                toastLabel.pin.bottom(to: view.edge.top).marginBottom(12).hCenter()
            case .bottom:
                toastLabel.pin.bottom(to: view.edge.bottom).marginBottom(12).hCenter()
            }
            
            toastLabel.superview?.flex.markDirty()
            self.view.flex.layout()
            
        case .snapKit:
            toastLabel.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(ButtonGridSystem.getMargin())
                switch anchorPosition {
                case .top:
                    make.top.equalTo(view.snp.top).offset(12)
                case .bottom:
                    make.bottom.equalTo(view.snp.bottom).offset(-12)
                }
            }
        }
        
        
        
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

enum LayoutLibrary {
    case flexLayout
    case snapKit
}

enum AnchorPosition {
    case top
    case bottom
}
