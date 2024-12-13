//
//  BaseViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import RxSwift
import SnapKit
import PinLayout
import FlexLayout

protocol LayoutConfigurable: AnyObject {
    var useSnapKit: Bool { get }
    var buttonContainerExists: Bool { get }

}

class BaseViewController: UIViewController, LayoutConfigurable {
    var useSnapKit: Bool {
        fatalError("useSnapKit는 반드시 하위 클래스에서 구현해야 합니다.")
    }
    var buttonContainerExists: Bool {
        fatalError("buttonContainerExists는 반드시 하위 클래스에서 구현해야 합니다.")
    }
    var disposeBag: DisposeBag = DisposeBag()
    let customNavigationBar = CMNavigationBar()
    private let navigationBarHeight: CGFloat = 44.0
    var errorView: ErrorPageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupErrorView()
        setupViewController()
        setupCustomNavigationBar()
        setupbackButton()
        view.backgroundColor = .cmBackgroundColor
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if additionalSafeAreaInsets.top != navigationBarHeight {
            additionalSafeAreaInsets.top = navigationBarHeight
        }
    }
    private func setupErrorView() {
        errorView = ErrorPageView(useSnapKit: useSnapKit)
        errorView?.isHidden = true
        if let errorView {
            view.addSubview(errorView)
        }
        if useSnapKit {
            errorView?.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    private func setupCustomNavigationBar() {
        view.addSubview(customNavigationBar)
        customNavigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-navigationBarHeight)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(navigationBarHeight)
        }
        if let errorView = errorView, !useSnapKit {
            errorView.pin.all(view.pin.safeArea)
            errorView.flex.layout()
        }
    }
    
    private func setupViewController() {
        navigationController?.isNavigationBarHidden = true
        view.tappedDismissKeyboard()
        // 제스처 인식기 delegate 설정
        if let gestureRecognizers = self.view.gestureRecognizers {
            for gesture in gestureRecognizers {
                gesture.delegate = self
            }
        }
    }
    
    private func setupbackButton() {
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            customNavigationBar.isBackButtonHidden = false
            customNavigationBar.setBackButtonAction(target: self, action: #selector(cmBackButtonTapped))
        } else {
            customNavigationBar.isBackButtonHidden = true
        }
    }
    
    @objc private func cmBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupLeftTitle(_ title: String, font: TextStyle = FontSystem.headline03_medium) {
        let titlLabel = UILabel()
        titlLabel.text = title
        titlLabel.textColor = .cmHeadLineTextColor
        titlLabel.applyStyle(textStyle: font)
        customNavigationBar.addLeftItems(items: [titlLabel])
    }
    
    func setupLogo() {
        let logoImageView = UIImageView(image: UIImage(named: "navigationLogo"))
        logoImageView.snp.makeConstraints { make in
            make.width.equalTo(logoImageView.image!.getRatio(height: 27))
        }
        logoImageView.contentMode = .scaleAspectFit
        customNavigationBar.addLeftItems(items: [logoImageView])
    }
    
    // 에러 뷰를 숨기는 함수
    func hideErrorView() {
        errorView?.isHidden = true
    }
    
    func handleError(_ error: PresentationError, toastAction: (() -> Void)? = nil) {
        switch error {
        case .showErrorPage:
            if let errorView {
                view.bringSubviewToFront(errorView)
            }
            view.bringSubviewToFront(customNavigationBar)
            customNavigationBar.isRightItemsHidden = true
            errorView?.isHidden = false
            if !useSnapKit {
                errorView?.flex.layout()
                view.setNeedsLayout()
                view.layoutIfNeeded()
            }
        case .showToastMessage(let message):
            showToast(message: message, buttonContainerExists: buttonContainerExists) {
                toastAction?()
            }
        case .unauthorized:
            logout()
        }
    }
    
    func logout() {
        showCMAlert(titleText: "유저 정보가 만료되었습니다.\n다시 로그인해주세요.", importantButtonText: "확인", commonButtonText: nil, importantAction:  {
            UnauthorizedErrorHandler.shared.handleError()
            let reactor = DIContainerService.shared.makeAuthReactor()
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(UINavigationController(rootViewController: SignInViewController(reactor: reactor)), animated: true)
        })
    }

}

extension BaseViewController: UIGestureRecognizerDelegate { 
    // UIGestureRecognizerDelegate 메소드
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 터치된 뷰가 send 버튼이면 제스쳐 무시 -> 버튼 클릭 우선
        if let button = touch.view as? UIButton, button.tag == 999 {
            return false
        }
        return true
    }
}
