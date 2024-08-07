//
//  TabBarController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import SnapKit

final class TabBarController: UITabBarController, UITabBarControllerDelegate {
    private let isNonMember: Bool
    private(set) var preViewControllerIndex: Int = 0
    var isAddView: Bool = false
    
    init(isNonMember: Bool = false) {
        self.isNonMember = isNonMember
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabbarLayout()
        settupTabbar()
        checkUnreadMessages()
    }
    
    private func setupTabbarLayout() {
        tabBar.backgroundColor = .white
        tabBar.layer.cornerRadius = 8
        tabBar.layer.masksToBounds = true
        tabBar.tintColor = .cmPrimaryColor
    }
    
    private func settupTabbar() {
        let homeViewController = UINavigationController(rootViewController: HomeViewController(reactor: HomeReactor()))
        let favoriteViewController = isNonMember ? UINavigationController(rootViewController: NonMembersAccessViewController(title: "찜 목록")) : UINavigationController(rootViewController: FavoriteListViewController(reactor: FavoriteReactor()))
        let addViewController = UINavigationController(rootViewController: BaseViewController()) // 네비게이션으로 연결할거기에 탭에는 빈 뷰컨트롤러 연결
        let chatViewController = isNonMember ? UINavigationController(rootViewController: NonMembersAccessViewController(title: "채팅 목록")) : UINavigationController(rootViewController: ChatListViewController())
        let mypageViewController = isNonMember ? UINavigationController(rootViewController: EmptyMyPageViewController()) : UINavigationController(rootViewController: MyPageViewController(reactor: DIContainerService.shared.makeMypageReactor()))
        
        homeViewController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(named: "homeTab")?.withTintColor(.grayScale200, renderingMode: .alwaysOriginal), selectedImage: UIImage(named: "homeTab_filled")?.withRenderingMode(.alwaysOriginal))
        favoriteViewController.tabBarItem = UITabBarItem(title: "찜", image: UIImage(named: "cmFavorite")?.withTintColor(.grayScale200, renderingMode: .alwaysOriginal), selectedImage: UIImage(named: "cmFavorite_filled")?.withRenderingMode(.alwaysOriginal))
        addViewController.tabBarItem = UITabBarItem(title: "등록", image: UIImage(named: "postTab")?.withTintColor(.grayScale200, renderingMode: .alwaysOriginal), selectedImage: UIImage(named: "postTab_filled")?.withRenderingMode(.alwaysOriginal))
        chatViewController.tabBarItem = UITabBarItem(title: "채팅", image: UIImage(named: "chatTab")?.withTintColor(.grayScale200, renderingMode: .alwaysOriginal), selectedImage: UIImage(named: "chatTab_filled")?.withRenderingMode(.alwaysOriginal))
        mypageViewController.tabBarItem = UITabBarItem(title: "마이", image: UIImage(named: "cmPerson")?.withTintColor(.grayScale200, renderingMode: .alwaysOriginal), selectedImage: UIImage(named: "cmPerson_filled")?.withRenderingMode(.alwaysOriginal))
        
        homeViewController.tabBarItem.tag = 0
        favoriteViewController.tabBarItem.tag = 1
        addViewController.tabBarItem.tag = 2
        chatViewController.tabBarItem.tag = 3
        mypageViewController.tabBarItem.tag = 4
        
        
        homeViewController.navigationBar.prefersLargeTitles = false
        favoriteViewController.navigationBar.prefersLargeTitles = false
        chatViewController.navigationBar.prefersLargeTitles = false
        mypageViewController.navigationBar.prefersLargeTitles = false
        setViewControllers([homeViewController, favoriteViewController, addViewController, chatViewController, mypageViewController], animated: true)
//        viewControllers = [homeViewController, favoriteViewController, addViewController, chatViewController, mypageViewController]
    }
    
    func checkUnreadMessages() {
        // MARK: - 임시 랜덤값 집어넣기
        let hasUnreadMessages = randomBoolean()
        print(hasUnreadMessages)
        
        if let chatTabBarItem = tabBar.items?[3] {
            if hasUnreadMessages {
                chatTabBarItem.image = UIImage(named: "chatTab_active")?.withTintColor(.grayScale200, renderingMode: .alwaysOriginal)
                chatTabBarItem.selectedImage = UIImage(named: "chatTab_active_filled")?.withRenderingMode(.alwaysOriginal)
            } else {
                chatTabBarItem.image = UIImage(named: "chatTab")?.withTintColor(.grayScale200, renderingMode: .alwaysOriginal)
                chatTabBarItem.selectedImage = UIImage(named: "chatTab_filled")?.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    // MARK: - 임시 랜덤 값 함수
    func randomBoolean() -> Bool {
        return Bool.random()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let viewControllers = tabBarController.viewControllers,
           let index = viewControllers.firstIndex(of: viewController) {
            if index == 2 {
                if isAddView { return false }
                let postVC = isNonMember ? NonMembersAccessViewController(title: "등록 하기", isAdd: true) : AddViewController(reactor: DIContainerService.shared.makeAddReactor())
                if let navVC = viewControllers[2] as? UINavigationController {
                    isAddView = true
                    tabBarController.tabBar.isHidden = true
                    navVC.pushViewController(postVC, animated: true)
                }

            } else {
                preViewControllerIndex = index
            }
        }
        return true 
    }
}

