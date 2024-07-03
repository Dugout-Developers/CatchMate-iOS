//
//  CMDefaultFilledButton.swift
//  CatchMate
//
//  Created by 방유빈 on 6/23/24.
//

import UIKit

class CMDefaultFilledButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    init(frame: CGRect = .zero, title: String, isRound: Bool = false) {
        super.init(frame: frame)
        setupButton(title, isRound)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupButton(_ title: String, _ isRound: Bool) {
        clipsToBounds = true
        layer.cornerRadius = isRound ? 20 : 8
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .disabled)
        applyStyle(textStyle: FontSystem.body02_semiBold)
        addTarget(self, action: #selector(updateBackgroundColor), for: .allEvents)
        updateBackgroundColor()
    }
    
    @objc private func updateBackgroundColor() {
        backgroundColor = isEnabled ? .cmPrimaryColor : .cmDisabledButtonColor
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                animate(scale: 0.95)
            } else {
                animate(scale: 1.0)
            }
        }
    }
    
    private func animate(scale: CGFloat) {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
    }
}
