//
//  CMActionMenu.swift
//  CatchMate
//
//  Created by 방유빈 on 8/27/24.
//

import UIKit
import SnapKit
/*
 사용 예시
 let menuVC = CMActionMenu()

 // 메뉴 항목 설정
 menuVC.menuItems = [
     MenuItem(title: "찜하기", action: {
         print("찜하기 선택됨")
     }),
     MenuItem(title: "공유하기", action: {
         print("공유하기 선택됨")
     }),
     MenuItem(title: "신고하기", textColor: UIColor.cmPrimaryColor, action: {
         print("신고하기 선택됨")
     })  // 신고하기는 빨간색으로 표시
 ]

 // 메뉴 화면을 모달로 표시
 menuVC.modalPresentationStyle = .overFullScreen
 present(menuVC, animated: false, completion: nil)

 */
struct MenuItem {
    let title: String
    let textColor: UIColor
    let action: () -> Void
    
    init(title: String, textColor: UIColor = .cmBodyTextColor, action: @escaping () -> Void) {
        self.title = title
        self.textColor = textColor
        self.action = action
    }
}

final class CMActionMenu: UIViewController {
    private let navigationBarHeight: CGFloat = 44.0
    var menuItems: [MenuItem] = []
    
    private let dimView = UIView()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDimView()
        setupStackView()
        setupMenuItems()
    }
    
    private func setupDimView() {
        dimView.backgroundColor = UIColor.opacity400
        dimView.frame = self.view.bounds
        view.addSubview(dimView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        dimView.addGestureRecognizer(tapGesture)
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.layer.cornerRadius = 8
        stackView.backgroundColor = .white
        stackView.clipsToBounds = true
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(navigationBarHeight+12)
            make.trailing.equalToSuperview().inset(18)
            make.width.equalTo(112)
        }
    }
    
    private func setupMenuItems() {
        for (index, item) in menuItems.enumerated() {
            let menuItemView = MenuItemView(title: item.title, textColor: item.textColor)
            menuItemView.isUserInteractionEnabled = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(menuItemTapped(_:)))
            menuItemView.addGestureRecognizer(tapGesture)
            
            menuItemView.tag = index
            stackView.addArrangedSubview(menuItemView)
            
            // 마지막 항목에는 구분선이 보이지 않도록 설정
            if index == menuItems.count - 1 {
                menuItemView.hideSeparator()
            }
        }
    }
    
    @objc private func menuItemTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: false) { [weak self] in
            guard let self = self else { return }
            if let tag = sender.view?.tag, menuItems.indices.contains(tag) {
                menuItems[tag].action()
            }
        }
    }
    
    @objc private func dismissMenu() {
        dismiss(animated: false, completion: nil)
    }
}


final class MenuItemView: UIView {
    private let titleLabel = UILabel()
    private let separator = UIView()
    
    init(title: String, textColor: UIColor = .black) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        titleLabel.textColor = textColor
        titleLabel.applyStyle(textStyle: FontSystem.body02_medium)
        addSubview(titleLabel)
        
        separator.backgroundColor = UIColor.cmStrokeColor
        addSubview(separator)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }
        separator.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        self.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideSeparator() {
        separator.isHidden = true
    }
}
