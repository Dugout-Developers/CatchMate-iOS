//
//  CMToastMessage.swift
//  CatchMate
//
//  Created by 방유빈 on 7/14/24.
//

import UIKit


final class CMToastMessageLabel: UILabel {
    private let textInsets: UIEdgeInsets = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
    
    init(message: String) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.opacity600
        self.textColor = UIColor.white
        self.textAlignment = .center
        self.applyStyle(textStyle: FontSystem.body02_medium)
        self.text = message
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.numberOfLines = 0
        self.invalidateIntrinsicContentSize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let sizeThatFits = super.sizeThatFits(size)
        return CGSize(width: sizeThatFits.width + textInsets.left + textInsets.right,
                      height: sizeThatFits.height + textInsets.top + textInsets.bottom)
    }
}

