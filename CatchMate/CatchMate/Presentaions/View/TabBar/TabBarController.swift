//
//  TabBarController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import SnapKit

final class TabBarController: UITabBarController {
    private let isNonMember: Bool
    
    init(isNonMember: Bool = false) {
        self.isNonMember = isNonMember
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        UITabBar.appearance().backgroundColor = .white
        UITabBar.appearance().tintColor = .cmPrimaryColor
    }
    
    private func configureTabBar() {
        let homeViewController = UINavigationController(rootViewController: HomeViewController(reactor: HomeReactor()))
        let chatViewController = isNonMember ? UINavigationController(rootViewController: NonMembersAccessViewController(title: "채팅 목록")) : UINavigationController(rootViewController: ChatListViewController())
        let addViewController = isNonMember ? UINavigationController(rootViewController: NonMembersAccessViewController(title: "게시글 등록")) : UINavigationController(rootViewController: AddViewController())
        let notiViewController = isNonMember ? UINavigationController(rootViewController: NonMembersAccessViewController(title: "알림")) : UINavigationController(rootViewController: NotiViewController())
        let mypageViewController = isNonMember ? UINavigationController(rootViewController: NonMembersAccessViewController(title: "내 정보")) : UINavigationController(rootViewController: MyPageViewController())
        
        homeViewController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house.fill"), tag: 0)
        chatViewController.tabBarItem = UITabBarItem(title: "채팅", image: UIImage(systemName: "message.fill"), tag: 1)
        addViewController.tabBarItem = UITabBarItem(title: "등록", image: UIImage(systemName: "plus.app"), tag: 2)
        notiViewController.tabBarItem = UITabBarItem(title: "알림", image: UIImage(systemName: "bell.fill"), tag: 3)
        mypageViewController.tabBarItem = UITabBarItem(title: "마이", image: UIImage(systemName: "person.fill"), tag: 4)
        
        homeViewController.navigationBar.prefersLargeTitles = false
        chatViewController.navigationBar.prefersLargeTitles = false
        addViewController.navigationBar.prefersLargeTitles = false
        notiViewController.navigationBar.prefersLargeTitles = false
        mypageViewController.navigationBar.prefersLargeTitles = false
        
        self.viewControllers = [homeViewController, chatViewController, addViewController, notiViewController, mypageViewController]
        delegate = self
    }
}

extension TabBarController: UITabBarControllerDelegate {
    
}
