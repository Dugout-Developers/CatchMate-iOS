//
//  UIView+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit

extension UIView {
    /// 배경 탭하면 키보드 내리기
    func tappedDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        self.endEditing(true)
    }
    
    func addSubviews(views: [UIView]) {
        views.forEach {
            self.addSubview($0)
        }
    }
}
