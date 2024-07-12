//
//  PaddingLabel.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit

class PaddingLabel: UILabel {
    private var padding = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
    var isSelected: Bool = false {
        didSet {
            updateClicked()
        }
    }

    convenience init(title: String) {
        self.init()
        self.text = title
        self.backgroundColor = .grayScale50
        self.textColor = .cmNonImportantTextColor
        self.applyStyle(textStyle: FontSystem.body02_semiBold)
        self.layer.cornerRadius = 18
        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right

        return contentSize
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let adjustedSize = CGSize(width: size.width - padding.left - padding.right,
                                  height: size.height - padding.top - padding.bottom)
        var contentSize = super.sizeThatFits(adjustedSize)
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right

        return contentSize
    }

    override var bounds: CGRect {
        didSet {
            if bounds.size != oldValue.size {
                invalidateIntrinsicContentSize()
            }
        }
    }
    private func updateClicked() {
        if isSelected {
            backgroundColor = .cmPrimaryColor
            textColor = .white
        } else {
            backgroundColor = .grayScale50
            textColor = .cmNonImportantTextColor
        }
    }
}

