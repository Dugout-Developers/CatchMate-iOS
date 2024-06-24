//
//  CMDefaultBorderedButton.swift
//  CatchMate
//
//  Created by 방유빈 on 6/24/24.
//

import UIKit

/// 라디오버튼용 보더 버튼
/// 높이 알맞게 설정해주기
class CMDefaultBorderedButton: UIButton {

    var isSelecte: Bool = false {
        didSet {
            updateBorderColor()
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
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.grayScale400.cgColor
        setTitleColor(.grayScale400, for: .normal)
        
        addTarget(self, action: #selector(updateBorderColor), for: .allEvents)
        updateBorderColor()
    }
    
    @objc private func updateBorderColor() {
        if isSelecte {
            layer.borderColor = UIColor.cmPrimaryColor.cgColor
            setTitleColor(.cmPrimaryColor, for: .normal)
        } else {
            layer.borderColor = UIColor.grayScale400.cgColor
            setTitleColor(.grayScale400, for: .normal)
        }
    }
}
