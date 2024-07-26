//
//  UILabel+Extensions.swift
//  CatchMate
//
//  Created by 방유빈 on 7/24/24.
//
import UIKit

extension UILabel {
    func setCornerRadius(_ radius: CGFloat, forCorners corners: UIRectCorner) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
