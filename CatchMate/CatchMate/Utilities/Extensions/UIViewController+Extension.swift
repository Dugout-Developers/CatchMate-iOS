//
//  UIViewController+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 6/15/24.
//

import UIKit

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
    
    /// 네비게이션 뒤로가기 버튼
    /// -> 사용방법: a에서 b로 이동한다면 a에서 선언
    func configNavigationBackButton() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: imageConfig)
        navigationController?.navigationBar.backIndicatorImage = backImage
        backImage?.accessibilityLabel = "뒤로가기"
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = .cmPrimaryColor
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

