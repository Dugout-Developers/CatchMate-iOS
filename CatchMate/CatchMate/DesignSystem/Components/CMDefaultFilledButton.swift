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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        layer.cornerRadius = 4
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .disabled)
        
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
