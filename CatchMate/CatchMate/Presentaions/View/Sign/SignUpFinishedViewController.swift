//
//  SignUpFinishedViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import RxCocoa

final class SignUpFinishedViewController: BaseViewController{
    override var useSnapKit: Bool {
        return false
    }
    override var buttonContainerExists: Bool {
        return true
    }
    private let containerView = UIView()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "congratulations")
        return imageView
    }()
    
    private let finishedLabel: UILabel = {
        let label = UILabel()
        label.text = "회원가입 완료"
        label.textColor = .cmHeadLineTextColor
        label.applyStyle(textStyle: FontSystem.pageTitle)
        return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = "함께 할수록 더 재미있는 야구 직관\n캐치메이트에서 구해보세요!"
        label.textColor = .cmNonImportantTextColor
        label.applyStyle(textStyle: FontSystem.body02_semiBold)
        label.textAlignment = .center
        return label
    }()
    
    private let nextButton = CMDefaultFilledButton(title: "다음")

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        customNavigationBar.isBackButtonHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.all(view.pin.safeArea).marginBottom(BottomMargin.safeArea-view.safeAreaInsets.bottom)
        containerView.flex.layout()
    }
    
}


// MARK: - bind
extension SignUpFinishedViewController {
    func bind() {
        nextButton.rx.tap
            .withUnretained(self)
            .subscribe { _, _ in
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(TabBarController(), animated: true)
            }
            .disposed(by: disposeBag)
        
    }
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
