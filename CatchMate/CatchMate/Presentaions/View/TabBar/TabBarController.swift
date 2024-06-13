//
//  TabBarController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import SnapKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        UITabBar.appearance().backgroundColor = .white
        UITabBar.appearance().tintColor = .CmPrimaryColor
    }
    
    private func configureTabBar() {
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        let chatViewController = UINavigationController(rootViewController: ChatListViewController())
        let addViewController = UINavigationController(rootViewController: AddViewController())
        let notiViewController = UINavigationController(rootViewController: NotiViewController())
        let mypageViewController = UINavigationController(rootViewController: MyPageViewController())
        
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
