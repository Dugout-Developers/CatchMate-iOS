//
//  BaseViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import RxSwift
import SnapKit

class BaseViewController: UIViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    let customNavigationBar = CMNavigationBar()
    private let navigationBarHeight: CGFloat = 44.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupCustomNavigationBar()
        setupbackButton()
        view.backgroundColor = .cmBackgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setupbackButton()
        if let tabBarController = tabBarController, tabBarController.selectedIndex != 2 {
            tabBarController.tabBar.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        tabBarController?.tabBar.isHidden = false
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
    
    func setupLeftTitle(_ title: String) {
        let titlLabel = UILabel()
        titlLabel.text = title
        titlLabel.textColor = .cmHeadLineTextColor
        titlLabel.applyStyle(textStyle: FontSystem.headline03_medium)
        customNavigationBar.addLeftItems(items: [titlLabel])
    }
    
    func setupLogo() {
        let logoImageView = UIImageView(image: UIImage(named: "navigationLogo"))
        logoImageView.contentMode = .scaleAspectFit
        customNavigationBar.addLeftItems(items: [logoImageView])
    }
}
