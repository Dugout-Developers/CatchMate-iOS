//
//  DefaultsPaddingLabel.swift
//  CatchMate
//
//  Created by 방유빈 on 7/15/24.
//

import UIKit


class DefaultsPaddingLabel: UILabel {
    private var padding: UIEdgeInsets = UIEdgeInsets(top: 4.0, left: 10.0, bottom: 4.0, right: 10.0)
    
    override init(frame: CGRect) {
        self.padding = UIEdgeInsets(top: 4.0, left: 10.0, bottom: 4.0, right: 10.0)
        super.init(frame: frame)
        self.applyStyle(textStyle: FontSystem.caption01_medium)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        self.padding = UIEdgeInsets(top: 4.0, left: 10.0, bottom: 4.0, right: 10.0)
        super.init(coder: coder)
        self.applyStyle(textStyle: FontSystem.caption01_medium)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
    }
    
    convenience init(padding: UIEdgeInsets) {
        self.init(frame: .zero)
        self.padding = padding
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
}
