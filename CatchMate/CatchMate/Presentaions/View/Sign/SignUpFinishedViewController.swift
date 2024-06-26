//
//  SignUpFinishedViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import UIKit
import FlexLayout
import PinLayout
import ReactorKit
import RxSwift
import RxCocoa

final class SignUpFinishedViewController: UIViewController , View {
    var disposeBag = DisposeBag()
    var reactor: SignReactor
    
    private let containerView = UIView()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "EmptyPrimary")
        return imageView
    }()
    
    private let finishedLabel: UILabel = {
        let label = UILabel()
        label.text = "회원가입 완료"
        label.textColor = .cmHeadLineTextColor
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "함께 할수록 더 재미있는 야구 직관\n캐치메이트에서 구해보세요!"
        label.textColor = .cmNonImportantTextColor
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private let nextButton: CMDefaultFilledButton = {
        let button = CMDefaultFilledButton()
        button.setTitle("다음", for: .normal)
        return button
    }()

    
    init(reactor: SignReactor) {
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
        hideNavigationBackButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.tappedDismissKeyboard()
    }
}


// MARK: - bind
extension SignUpFinishedViewController {
    func bind(reactor: SignReactor) {
        nextButton.rx.tap
            .withUnretained(self)
            .subscribe { _, _ in
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(TabBarController(), animated: true)
            }
            .disposed(by: disposeBag)
        
//        nextButton.rx.tap
//            .map { Reactor.Action.signUpUser }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
//
//        
//        
//        reactor.state
//            .map { $0.isSignUp }
//            .distinctUntilChanged()
//            .subscribe(onNext: { [weak self] isSignUp in
//                if isSignUp == true {
//                    self?.navigateToNextPage()
//                } else if isSignUp == false {
//                    self?.showErrorAlert()
//                }
//            })
//            .disposed(by: disposeBag)

    }
    
//    private func navigateToNextPage() {
//            // Logic to navigate to the next page
//            let nextViewController = UIViewController()
//            navigationController?.pushViewController(nextViewController, animated: true)
//        }
//        
//        private func showErrorAlert() {
//            let alert = UIAlertController(title: "Error", message: "Sign up failed.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            present(alert, animated: true, completion: nil)
//        }
}

// MARK: - UI
extension SignUpFinishedViewController {
    private func setupUI() {
        view.addSubview(containerView)
        containerView.flex.marginHorizontal(24).justifyContent(.start).alignItems(.center).define { flex in
            flex.addItem().direction(.column).justifyContent(.center).alignItems(.center).define { flex in
                flex.addItem(logoImageView).size(88).marginBottom(56)
                flex.addItem(finishedLabel).marginBottom(24)
                flex.addItem(subLabel)
            }.grow(1)
            flex.addItem(nextButton).width(100%).height(50).marginBottom(34)
        }
    }
}
