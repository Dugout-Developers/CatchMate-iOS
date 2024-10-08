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

class BaseViewController: UIViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    let customNavigationBar = CMNavigationBar()
    private let navigationBarHeight: CGFloat = 44.0
    var errorView: ErrorPageView? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    private func setupCustomNavigationBar() {
        view.addSubview(customNavigationBar)
        customNavigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-navigationBarHeight)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(navigationBarHeight)
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
         errorView?.removeFromSuperview()
         errorView = nil
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
