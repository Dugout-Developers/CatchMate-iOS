//
//  MessageBoxLabel.swift
//  CatchMate
//
//  Created by 방유빈 on 7/24/24.
//

import UIKit

final class MessageBoxLabel: UILabel {
    var padding = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

    override var text: String? {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            if preferredMaxLayoutWidth != bounds.width - (padding.left + padding.right) {
                preferredMaxLayoutWidth = bounds.width - (padding.left + padding.right)
                invalidateIntrinsicContentSize() // 크기 갱신
            }
        }
    }

    override func drawText(in rect: CGRect) {
        let insets = padding
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                      height: size.height + padding.top + padding.bottom)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if preferredMaxLayoutWidth != bounds.width - (padding.left + padding.right) {
            preferredMaxLayoutWidth = bounds.width - (padding.left + padding.right)
        }
    }
}
