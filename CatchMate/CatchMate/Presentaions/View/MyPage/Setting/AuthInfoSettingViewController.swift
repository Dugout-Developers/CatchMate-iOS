//
//  AuthInfoSettingViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/7/24.
//

import UIKit
import SnapKit

final class AuthInfoSettingViewController: BaseViewController {
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    private let loginInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "로그인 정보"
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    private let infoContainer = UIView()
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let deleteIDButton: UIButton = {
        let button = UIButton()
        button.setTitle("탈퇴하기", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        let underlineAttribute: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        button.applyStyle(textStyle: FontSystem.body02_medium, anyAttr: underlineAttribute)
        button.backgroundColor = .clear
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("계정 정보")
        setupUI()
        bind()
    }
    
    init(loginData: LoginData) {
        super.init(nibName: nil, bundle: nil)
        self.emailLabel.text = loginData.email
        self.logoImageView.image = UIImage(named: loginData.loginTypeImageName)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        view.addSubviews(views: [loginInfoLabel, infoContainer, deleteIDButton])
        infoContainer.addSubviews(views: [emailLabel, logoImageView])
        
        loginInfoLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
            make.top.equalTo(view.safeAreaLayoutGuide).offset(25)
        }
        infoContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(loginInfoLabel)
            make.top.equalTo(loginInfoLabel.snp.bottom).offset(12)
            make.height.equalTo(52)
        }
        emailLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        logoImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.leading.equalTo(emailLabel.snp.trailing).offset(20)
        }
        logoImageView.setContentHuggingPriority(.required, for: .horizontal)
        logoImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        deleteIDButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-100)
        }

    }
    
    private func bind() {
        deleteIDButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.showCMAlert(titleText: "탈퇴하시겠습니까?", importantButtonText: "네니오", commonButtonText: "아니요") {
                    
                } commonAction: {
                    
                }

            }
            .disposed(by: disposeBag)
    }
}
