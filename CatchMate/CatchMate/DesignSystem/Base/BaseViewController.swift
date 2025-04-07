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
    private let navigationBackgroundView = UIView()
    private let navigationBarHeight: CGFloat = 44.0
    var errorView: ErrorPageView?
    private var isNavigationBarHidden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupErrorView()
        setupViewController()
        setupCustomNavigationBar()
        setupbackButton()
        setupKeyboardObservers()
        view.backgroundColor = .cmBackgroundColor
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isNavigationBarHidden { // 숨김 상태가 아닐 때만 업데이트
            if additionalSafeAreaInsets.top != navigationBarHeight {
                additionalSafeAreaInsets.top = navigationBarHeight
            }
        } else {
            if additionalSafeAreaInsets.top != 0 {
                additionalSafeAreaInsets.top = 0 // Safe Area 복원
            }
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    @objc private func handleKeyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        // 현재 FirstResponder가 누군지 찾기
        if let currentResponder = UIResponder.currentFirstResponder as? UIView {
            let responderFrameInWindow = currentResponder.convert(currentResponder.bounds, to: view.window)
            let keyboardOriginY = keyboardFrame.origin.y

            // 텍스트필드 하단이 키보드보다 아래에 있으면 -> 겹치는 부분 만큼 올림
            let overlap = responderFrameInWindow.maxY - keyboardOriginY + 20 // 여유 padding

            if overlap > 0 {
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -overlap)
                }
            }
        }
    }

    @objc private func handleKeyboardWillHide(_ notification: Notification) {
        view.transform = .identity
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
        navigationBackgroundView.backgroundColor = .white
        view.addSubview(navigationBackgroundView)
        view.addSubview(customNavigationBar)

        navigationBackgroundView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

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
    func navigationBarHidden() {
        isNavigationBarHidden = true // 네비게이션 바 숨김 상태로 설정
        customNavigationBar.removeFromSuperview()
        navigationBackgroundView.removeFromSuperview()
        view.setNeedsLayout() // 레이아웃 강제 업데이트
        view.layoutIfNeeded()
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
            make.width.equalTo(logoImageView.image!.getRatio(height: 20))
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
            let _ = TokenDataSourceImpl().deleteTokenAll()
    
            let reactor = DIContainerService.shared.makeAuthReactor()
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(UINavigationController(rootViewController: SignInViewController(reactor: reactor)), animated: true)
        })
    }

    func setNavigationBackgroundColor(_ color: UIColor) {
        navigationBackgroundView.backgroundColor = color
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

extension UIResponder {
    private static weak var _currentFirstResponder: UIResponder?

    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil

        // UIResponder 체인에 있는 모든 객체에 액션을 전달하여 FirstResponder 찾기
        UIApplication.shared.sendAction(#selector(findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    @objc private func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }
}
