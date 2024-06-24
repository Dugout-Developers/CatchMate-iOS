//
//  SignUpViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/24/24.
//

import UIKit
import FlexLayout
import PinLayout

final class SignUpViewController: UIViewController {
    private let containerView = UIView()
    private let titleLabel1: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "딱맞는 직관 친구를 구하기 위해"
        label.adjustsFontForContentSizeCategory = true
        label.font = .systemFont(ofSize: 28)
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let titleLabel2: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "정보를 입력해주세요."
        label.adjustsFontForContentSizeCategory = true
        label.font = .systemFont(ofSize: 28)
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let requiredMark: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "requiredMark")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let countLabel: UILabel = {
        let label = UILabel()
        label.text = "0/10"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    
    private let nickNameTextField: CMTextField = {
        let textField = CMTextField()
        textField.placeholder = "닉네임을 입력해주세요"
        return textField
    }()
    
    private let birthLabel: UILabel = {
        let label = UILabel()
        label.text = "생년월일"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    
    private let birthTextField: CMTextField = {
        let textField = CMTextField()
        textField.placeholder = "생년월일을 입력해주세요 예) 000000"
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "성별"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    
    private let womanButton: CMDefaultBorderedButton = {
        let button = CMDefaultBorderedButton()
        button.setTitle("여성", for: .normal)
        return button
    }()
    
    private let manButton: CMDefaultBorderedButton = {
        let button = CMDefaultBorderedButton()
        button.setTitle("남성", for: .normal)
        return button
    }()
    
    private let nextButton: CMDefaultFilledButton = {
        let button = CMDefaultFilledButton()
        button.setTitle("다음", for: .normal)
//        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.all(view.pin.safeArea)
        containerView.flex.layout()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.tappedDismissKeyboard()
    }
}

// MARK: - UI
extension SignUpViewController {
    private func setupUI() {
        view.addSubview(containerView)
        let sectionMargin = 32.0
        let itemMargin = 12.0
        
        containerView.flex.direction(.column).marginHorizontal(24).justifyContent(.start).alignItems(.start).define { flex in
            flex.addItem(titleLabel1).marginTop(48).marginBottom(4)
            flex.addItem().direction(.row).alignItems(.center).define { flex in
                flex.addItem(titleLabel2).marginRight(6)
                flex.addItem(requiredMark).size(6)
            }.marginBottom(40)
            flex.addItem().direction(.row).width(100%).justifyContent(.spaceBetween).define { flex in
                flex.addItem(nickNameLabel)
                flex.addItem(countLabel)
            }.marginBottom(itemMargin)
            flex.addItem(nickNameTextField).width(100%).marginBottom(sectionMargin)
            flex.addItem(birthLabel).marginBottom(itemMargin)
            flex.addItem(birthTextField).width(100%).marginBottom(sectionMargin)
            flex.addItem(genderLabel).marginBottom(itemMargin)
            flex.addItem().direction(.row).height(50).width(100%).justifyContent(.spaceBetween).define { flex in
                flex.addItem(womanButton).grow(1).marginRight(9)
                flex.addItem(manButton).grow(1)
            }
            flex.addItem().width(100%).grow(1).direction(.column).justifyContent(.end).define { flex in
                flex.addItem(nextButton).width(100%).height(50)
            }
        }
    }
}
