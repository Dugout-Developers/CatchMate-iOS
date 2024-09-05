//
//  SceneDelegate.swift
//  CatchMate
//
//  Created by 방유빈 on 6/11/24.
//

import UIKit
import RxSwift
import RxKakaoSDKAuth
import KakaoSDKAuth
import NaverThirdPartyLogin

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private let disposeBag = DisposeBag()
    private var authManager: AuthManager?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let manager = AuthManager(tokenDS: TokenDataSourceImpl())
        self.authManager = manager  // AuthManager를 강하게 참조하여 유지
        manager.attemptAutoLogin()
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe { scene, result in
                if result {
                    scene.moveMainTab()
                } else {
                    scene.moveSignIn()
                }
                self.authManager = nil
            } onError: { error in
                print(error)
                self.moveSignIn()
                self.authManager = nil
            }
            .disposed(by: disposeBag)

    }
    
    private func moveMainTab() {
        let tabViewController = TabBarController()
        window?.rootViewController = tabViewController
        window?.makeKeyAndVisible()
    }
    
    private func moveSignIn() {
        let reactor = DIContainerService.shared.makeAuthReactor()
        let signInViewController = SignInViewController(reactor: reactor)
        window?.rootViewController = UINavigationController(rootViewController: signInViewController)
        window?.makeKeyAndVisible()
    }
    
    // 사용법 :
    // (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootView(UIViewController(), animated: true)
    /// 루트뷰 변경
    func changeRootView(_ viewController: UIViewController, animated: Bool) {
        guard let window = self.window else { return }
        
        if animated {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            window.layer.add(transition, forKey: kCATransition)
        }
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}
// MARK: - SNS Login
extension SceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.rx.handleOpenUrl(url: url)
            }
            
            if url.absoluteString.hasPrefix("catchmate") {
                _ = NaverThirdPartyLoginConnection.getSharedInstance()?.application(UIApplication.shared, open: url, options: [:])
            }

        }
        
    }
}

