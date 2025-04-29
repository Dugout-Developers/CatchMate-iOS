//
//  AuthInfoSettingViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/7/24.
//

import UIKit
import SnapKit
import ReactorKit

final class AuthInfoSettingViewController: BaseViewController, View {
    var reactor: AuthInfoReactor
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    private let infoContainer = UIView()
    private let loginInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "로그인 정보"
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body02_medium)
        return label
    }()
    private let emailContainer = UIView()
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
    
    private let logoutButton = CMDefaultFilledButton(title: "로그아웃")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle("계정 정보")
        setupUI()
        bind(reactor: reactor)
        view.backgroundColor = .cmGrayBackgroundColor
        emailContainer.backgroundColor = .cmGrayBackgroundColor
        infoContainer.backgroundColor = .white
    }
    
    init(loginData: LoginData, reactor: AuthInfoReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
        self.emailLabel.text = loginData.email
        self.logoImageView.image = UIImage(named: loginData.loginTypeImageName)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        view.addSubviews(views: [infoContainer, deleteIDButton, logoutButton])
        infoContainer.addSubviews(views: [loginInfoLabel, emailContainer])
        emailContainer.addSubviews(views: [emailLabel, logoImageView])
        infoContainer.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(emailContainer).offset(70)
        }
        
        loginInfoLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
            make.top.equalTo(view.safeAreaLayoutGuide).offset(25)
        }
        emailContainer.snp.makeConstraints { make in
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
            make.bottom.equalTo(logoutButton.snp.top).offset(-20)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.leading.trailing.equalTo(loginInfoLabel)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-34)
        }

    }
    
    func bind(reactor: AuthInfoReactor) {
        reactor.state.map{$0.error}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe(onNext: { vc, error in
                vc.handleError(error)
            })
            .disposed(by: disposeBag)
        reactor.state.map{$0.eventTrigger}
            .subscribe { state in
                if state {
                    LoginUserDefaultsService.shared.deleteLoginData()
                    let reactor = DIContainerService.shared.makeAuthReactor()
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(UINavigationController(rootViewController: SignInViewController(reactor: reactor)), animated: true)
                }
            }
            .disposed(by: disposeBag)
        deleteIDButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.showCMAlert(titleText: "아직 함께할 경기가 많이 남았어요\n정말 떠나시겠어요?", importantButtonText: "네", commonButtonText: "아니요", importantAction:  {
                    reactor.action.onNext(.withdraw)
                })
            }
            .disposed(by: disposeBag)
        
        logoutButton.rx.tap
            .withUnretained(self)
            .subscribe { vc, _ in
                vc.showCMAlert(titleText: "로그아웃하시겠습니까?", importantButtonText: "네", commonButtonText: "아니요", importantAction:  {
                    reactor.action.onNext(.logout)
                })
            }
            .disposed(by: disposeBag)
    }
}
