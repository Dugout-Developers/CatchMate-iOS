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
import FirebaseRemoteConfig
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private let disposeBag = DisposeBag()
    private var authManager: AuthManager?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let launchStoryboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        let launchVC = launchStoryboard.instantiateViewController(withIdentifier: "LaunchScreenVC")
        
        window?.rootViewController = launchVC
        window?.makeKeyAndVisible()
        checkForUpdate()
    }
    
    /// 앱 실행 전에 업데이트 체크 & 로그인 진행
    func checkForUpdate() {
        AppVersionService.shared.fetchRemoteConfig { minimumVersion in
            guard let minimumVersion = minimumVersion else { return }
            
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
            
            if AppVersionService.shared.isVersionNewer(currentVersion: currentVersion, minimumVersion: minimumVersion) {
                DispatchQueue.main.async {
                    self.showForceUpdateAlert()
                }
            } else {
                DispatchQueue.main.async {
                    self.attemptLogin()
                }
            }
        }
    }
    
    /// Alert 요청 후 앱스토어 이동
    private func showForceUpdateAlert() {
        DispatchQueue.main.async {
            guard let window = self.window else { return }
            
            window.rootViewController?.showCMAlert(titleText: "최신 버전으로 업데이트해주세요", importantButtonText: "업데이트", commonButtonText: nil, importantAction: {
                self.openAppStore()
            })
        }
    }
    private func openAppStore() {
        let appID = "1234567890" // TODO: - 실제 앱 ID로 변경
        let appStoreURL = "itms-apps://itunes.apple.com/app/id\(appID)"
        let appStoreWebURL = "https://apps.apple.com/app/id\(appID)"
        
        if let url = URL(string: appStoreURL) {
            UIApplication.shared.open(url, options: [:]) { success in
                if !success, let webURL = URL(string: appStoreWebURL) {
                    // 앱스토어가 안 열리면 Safari에서 앱스토어 웹페이지 열기
                    UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
                }
            }
        } else if let webURL = URL(string: appStoreWebURL) {
            // URL이 잘못되었을 경우에도 Safari에서 열기
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
    private func attemptLogin() {
        let manager = AuthManager(tokenDS: TokenDataSourceImpl())
        self.authManager = manager
        
        manager.attemptAutoLogin()
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe { scene, result in
                if result {
                    do {
                        SocketService.shared = try SocketService()
                        print("✅ SocketService 인스턴스 생성 성공")
                        SocketService.shared?.connect()  // WebSocket 연결
                    } catch {
                        print("❌ SocketService 초기화 실패: \(error)")
                    }
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
        NotificationService.shared.checkNotificationPermissionStatus { isAllowed in
            NotificationCenter.default.post(name: .notificationStatusChanged, object: isAllowed)
        }
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

