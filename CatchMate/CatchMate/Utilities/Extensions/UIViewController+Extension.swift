//
//  UIViewController+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 6/15/24.
//

import UIKit
import SnapKit
extension UIViewController {
    /// Title leftBarButton
    func configNavigationLeftTitle(_ title: String) {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 20)
        label.textColor = .cmTextGray
        
        let leftItem = UIBarButtonItem(customView: label)
        let height: CGFloat = 24
        leftItem.customView?.snp.makeConstraints({ make in
            make.height.equalTo(height)
        })
        
        self.navigationItem.leftBarButtonItem = leftItem
    }
    /// logo leftBarButton
    func configNavigationLogo() {
        let image = UIImage(named: "navigationLogo")
        let logoView = UIImageView(image: image)
        
        
        let leftItem = UIBarButtonItem(customView: logoView)
        let height: CGFloat = 24
        leftItem.customView?.snp.makeConstraints({ make in
            make.height.equalTo(height)
            make.width.equalTo(image?.getRatio(height: height) ?? 0)
        })
        
        leftItem.isEnabled = false
        self.navigationItem.leftBarButtonItem = leftItem
    }
    func setupBackButton(title: String? = nil) {
        let backbuttonItem = UIView()
        let backbuttonImage = UIImageView(image: UIImage(named: "left"))
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .cmHeadLineTextColor
        titleLabel.applyStyle(textStyle: FontSystem.headline03_medium)
        backbuttonItem.addSubviews(views: [backbuttonImage, titleLabel])
        backbuttonImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(2)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(backbuttonImage.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        navigationItem.backBarButtonItem = UIBarButtonItem(customView: backbuttonItem)
        navigationItem.backBarButtonItem?.tintColor = .cmHeadLineTextColor
        
    }
    /// 네비게이션 뒤로가기 버튼
    /// -> 사용방법: a에서 b로 이동한다면 a에서 선언
    func configNavigationBackButton(_ text: String = "") {
        let backImage = UIImage(named: "left")?.withTintColor(.cmHeadLineTextColor, renderingMode: .alwaysOriginal)
        let backButton = UIButton(type: .custom)
        backButton.setImage(backImage, for: .normal)
        backButton.setTitle(text, for: .normal)
        backButton.sizeToFit()
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: backButton.frame.width + 18, height: 20))
        backButton.frame.origin.x = 18
        // 기본 바버튼 여백 제거 = 기본 iOS 백버튼 여백 16
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -16
        containerView.addSubview(backButton)
        
        let backBarButtonItem = UIBarButtonItem(customView: containerView)
        
        self.navigationItem.leftBarButtonItems = [negativeSpacer, backBarButtonItem]
    }
    // 백 버튼의 액션
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    
    /// 네비게이션 뒤로가기 버튼 숨기기
    /// -> 사용방법: a에서 b로 이동한다면 a에서 선언
    func hideNavigationBackButton() {
        self.navigationItem.hidesBackButton = true
    }
    
    /// 네비게이션 safeArea 까지의 배경색 설정
    func configNavigationBgColor(backgroundColor: UIColor = .cmBackgroundColor) {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = backgroundColor
        navigationBarAppearance.shadowColor = .clear // 밑줄 제거
        navigationBarAppearance.shadowImage = UIImage() // 밑줄 제거
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    }
    
    /// 알림창 띄우기
    func showAlert(message: String, title: String = "알림", isCancelButton: Bool = false, yesAction: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yes = UIAlertAction(title: "확인", style: .default) { _ in
            yesAction?()
        }
        
        if isCancelButton {
            let cancel = UIAlertAction(title: "취소", style: .destructive, handler: nil)
            alert.addAction(cancel)
        }
        alert.addAction(yes)
        
        present(alert, animated: true, completion: nil)
    }
}

