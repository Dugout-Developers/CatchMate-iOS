//
//  SignInViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/23/24.
//

import UIKit
import RxSwift
import ReactorKit
import RxKakaoSDKUser
import FlexLayout
import PinLayout

final class SignInViewController: BaseViewController, View {
    var reactor: AuthReactor
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
        label.applyStyle(textStyle: FontSystem.body03_medium)
        label.textColor = .cmNonImportantTextColor
        return label
    }()
    private let exploreButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setTitle("일단 둘러볼게요.", for: .normal)
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.cmNonImportantTextColor
        ]
        button.applyStyle(textStyle:  FontSystem.body03_medium, anyAttr: attributes)

        return button
    }()
    
    init (reactor: AuthReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUI()
        bind(reactor: reactor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(KeychainService.getToken(for: .refreshToken))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        exploreButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _, _ in
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(TabBarController(isNonMember: true), animated: true)
            })
            .disposed(by: disposeBag)
    }
}
// MARK: - Bind
extension SignInViewController {
    func bind(reactor: AuthReactor) {
        kakaoLoginButton.rx.tap
            .map{ Reactor.Action.kakaoLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        naverLoginButton.rx.tap
            .map{ Reactor.Action.naverLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.errorMessage }
            .distinctUntilChanged()
            .compactMap { $0 }
            .subscribe(onNext: { errorMessage in
                print("로그인 실패: \(errorMessage)")
                // 에러 메시지 표시
            })
            .disposed(by: disposeBag)
        
        appleLoginButton.rx.tap
            .map { Reactor.Action.appleLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { state -> LoginModel? in
                if let loginModel = state.loginModel {
                    return loginModel
                }
                return nil
            }
            .compactMap{$0}
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { vc, model in
                print("\(model)")
                vc.pushNextView(model)
            })
            .disposed(by: disposeBag)
    }
    
    private func pushNextView(_ model: LoginModel) {
        let state = model.isFirstLogin
        if !state {
            // 회원가입 이미한 유저일 경우
            let tabViewController = TabBarController()
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(tabViewController, animated: true)
        } else {
            let signReactor = DIContainerService.shared.makeSignReactor(model)
            let signUpViewController = SignUpViewController(reactor: signReactor)
            navigationController?.pushViewController(signUpViewController, animated: true)
        }
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
