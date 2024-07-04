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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupBackbutton()
        view.backgroundColor = .cmBackgroundColor
//        navigationItem.backBarButtonItem?.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setupViewController() {
        view.tappedDismissKeyboard()
        configNavigationBgColor()
    }
    
    private let contentHeight: CGFloat = 24
    
    func setupLeftTitle(_ title: String) {
        self.navigationItem.leftBarButtonItem = nil
        let leftViewContainer = UIView()
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 20)
        label.textColor = .cmTextGray
        leftViewContainer.addSubview(label)
        label.snp.makeConstraints({ make in
            make.leading.equalToSuperview().offset(self.navigationItem.backBarButtonItem == nil ? 18 : 12)
            make.top.bottom.equalToSuperview()
            make.height.equalTo(contentHeight)
        })
        
        let leftItem = UIBarButtonItem(customView: leftViewContainer)
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    func setupLogo() {
        self.navigationItem.leftBarButtonItem = nil
        let leftViewContainer = UIView()
        let image = UIImage(named: "navigationLogo")
        let logoView = UIImageView(image: image)
        

        leftViewContainer.addSubview(logoView)
        logoView.snp.makeConstraints({ make in
            make.leading.equalToSuperview().offset(self.navigationItem.backBarButtonItem == nil ? 18 : 12)
            make.top.bottom.equalToSuperview()
            make.height.equalTo(contentHeight)
            make.width.equalTo(image?.getRatio(height: contentHeight) ?? 0)
        })
        
        let leftItem = UIBarButtonItem(customView: leftViewContainer)
        leftItem.isEnabled = false
        
        self.navigationItem.leftBarButtonItem = leftItem
    }
    private let containerView = UIView()
    private func setupBackbutton() {
        let backImage = UIImageView(image: UIImage(named: "left"))
        backImage.contentMode = .scaleAspectFit
        containerView.addSubview(backImage)
        backImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        let backBarButtonItem = UIBarButtonItem(customView: containerView)
        navigationItem.backBarButtonItem?.tintColor = .cmHeadLineTextColor
    }
    
    @objc override func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
