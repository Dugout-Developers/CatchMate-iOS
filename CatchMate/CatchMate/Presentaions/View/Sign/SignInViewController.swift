//
//  SignInViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/23/24.
//

import UIKit
import FlexLayout
import PinLayout

final class SignInViewController: BaseViewController {
    private let containerView = UIView()
    private let logoContainerView = UIView()
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "EmptyPrimary")
        return imageView
    }()
    
    private let simpleLoginLabelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Simplelogin")
        return imageView
    }()
    
    private let kakaoLoginButton = CMImageButton(frame: .zero, image: UIImage(named: "kakaoLoginBtn"))
    private let naverLoginButton = CMImageButton(frame: .zero, image: UIImage(named: "naverLoginBtn"))
    private let appleLoginButton = CMImageButton(frame: .zero, image: UIImage(named: "appleLoginBtn"))

    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "또는"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let exploreButton: UIButton = {
        let button = UIButton(configuration: .plain())
        let buttonText = "일단 둘러볼게요."
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.cmNonImportantTextColor
        ]
        let attributedString = NSAttributedString(string: buttonText, attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUI()
        setupButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
    }
    
    private func setupView() {
        view.backgroundColor = .white
    }
}

// MARK: - Button
extension SignInViewController {
    private func setupButton() {
        kakaoLoginButton.addTarget(self, action: #selector(clickKakaoLoginButton), for: .touchUpInside)
    }
    @objc
    private func clickKakaoLoginButton(_ sender: UIButton) {
        let signUpViewController = SignUpViewController()
        navigationController?.pushViewController(signUpViewController, animated: true)
    }
}

// MARK: - UI
extension SignInViewController {
    private func setupUI() {
        view.addSubview(containerView)
        
        containerView.flex.direction(.column).justifyContent(.start).alignItems(.center).marginHorizontal(24).define { flex in
            flex.addItem(logoContainerView).width(100%).height(Screen.height / 2).justifyContent(.center).alignItems(.center).define { flex in
                flex.addItem(logoImageView).size(80)
            }.marginBottom(19)
            flex.addItem(simpleLoginLabelImageView).width(134).height(33).marginBottom(9)
            flex.addItem(kakaoLoginButton).height(50).marginBottom(25)
            flex.addItem().direction(.row).justifyContent(.spaceBetween).alignItems(.center).width(100%).define { flex in
                flex.addItem().backgroundColor(.cmStrokeColor).height(1).grow(1)
                flex.addItem(orLabel).marginHorizontal(16)
                flex.addItem().backgroundColor(.cmStrokeColor).height(1).grow(1)
            }.marginBottom(17)
            flex.addItem().direction(.row).justifyContent(.spaceBetween).alignItems(.center).define { flex in
                flex.addItem(naverLoginButton).size(48)
                flex.addItem().backgroundColor(.cmStrokeColor).height(16).width(1).marginHorizontal(24)
                flex.addItem(appleLoginButton).size(48)
            }
            flex.addItem(exploreButton).marginTop(24)
        }
    }
}
