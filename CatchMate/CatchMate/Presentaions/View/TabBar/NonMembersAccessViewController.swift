//
//  NonMembersAccessViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 7/1/24.
//

import UIKit
import RxSwift
import FlexLayout
import PinLayout

class NonMembersAccessViewController: BaseViewController {
    private let containerView = UIView()
    private var isAdd: Bool
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "회원 전용 페이지 입니다.\n로그인을 진행해주세요."
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .cmTextGray
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let signInPageButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setTitle("로그인 페이지로 이동 >", for: .normal)
        button.setTitleColor(.cmPrimaryColor, for: .normal)
        button.tintColor = .clear
        return button
    }()
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isAdd {
            if let tabBarController = tabBarController as? TabBarController {
                tabBarController.isAddView = false
                tabBarController.selectedIndex = tabBarController.preViewControllerIndex
            }
        }
    }
    init(title: String, isAdd: Bool = false) {
        self.isAdd = isAdd
        super.init(nibName: nil, bundle: nil)
        setupView(title: title)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    private func setupView(title: String) {
        view.backgroundColor = .cmBackgroundColor
        setupLeftTitle(title)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.all(view.pin.safeArea)
        containerView.flex.layout()
    }
    
    func bind() {
        signInPageButton.rx.tap
            .withUnretained(self)
            .subscribe { _, _ in
                let signReactorResult = DIContainerService.shared.makeAuthReactor()
                let signInViewController = SignInViewController(reactor: signReactorResult)
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(signInViewController, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UI
extension NonMembersAccessViewController {
    private func setupUI() {
        view.addSubview(containerView)
        
        containerView.flex.direction(.column).alignItems(.center).justifyContent(.center).define { flex in
            flex.addItem(infoLabel).marginBottom(20)
            flex.addItem(signInPageButton)
        }
    }
}
