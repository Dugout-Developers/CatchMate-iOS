//
//  AppDelegate.swift
//  CatchMate
//
//  Created by 방유빈 on 6/11/24.
//

import UIKit
import RxKakaoSDKCommon
import NaverThirdPartyLogin
import Firebase
import FirebaseMessaging
import UserNotifications
import FirebaseAnalytics
import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    private let disposeBag = DisposeBag()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
#if DEBUG
        Analytics.setAnalyticsCollectionEnabled(false) // 디버그 모드에서 비활성화
#endif
        // APNS 등록
//        if #available(iOS 10.0, *) {
//            UNUserNotificationCenter.current().delegate = self
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
//        } else {
//            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.ChatInfo.chatRoomId)
        
        if let notificationOption = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            let acceptStatus = notificationOption["acceptStatus"] as? String
            
            switch acceptStatus {
            case "PENDING":
                if let boardIdStr = notificationOption["boardId"] as? String, let boardId = Int(boardIdStr) {
                    moveApplyDetailView(boardId: boardId)
                } else {
                    LoggerService.shared.log(level: .error, "boardId 구할 수 없음")
                }
            case "ACCEPTED", nil:
                if let chatIdStr = notificationOption["chatRoomId"] as? String, let chatId = Int(chatIdStr) {
                    moveChatRoom(chatId: chatId)
                } else {
                    moveChatRoom(chatId: nil)
                }
            default:
                LoggerService.shared.log(level: .error, "acceptStatus 구할 수 없음")
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            if let kakaoAppKey = Bundle.main.kakaoLoginAPPKey {
                RxKakaoSDK.initSDK(appKey: kakaoAppKey)
            }
            
            if let instance = NaverThirdPartyLoginConnection.getSharedInstance() {
                instance.isNaverAppOauthEnable = true
                instance.isInAppOauthEnable = true
                instance.serviceUrlScheme = Bundle.main.naverUrlScheme
                instance.consumerKey = Bundle.main.naverLoginClientID
                instance.consumerSecret = Bundle.main.naverLoginClientSecret
                instance.appName = "CatchMate"
            }
            
            DispatchQueue.main.async {
                // 메인 작업이 필요할 경우
            }
        }
        return true
    }

    // 푸시 알림 등록
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("푸시 알림 수신 (foreground): \(userInfo)")
        
        if userInfo["acceptStatus"] == nil {
            if let chatId = userInfo["chatRoomId"] as? String {
                if let currentChatRoomId = UserDefaults.standard.string(forKey: UserDefaultsKeys.ChatInfo.chatRoomId) {
                    print(currentChatRoomId)
                    if currentChatRoomId == chatId {
                        completionHandler([])
                        return
                    }
                }
            }
        }
        completionHandler([.list, .banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("푸시 알림 수신 (background/terminated): \(userInfo)")
        let acceptStatus = userInfo["acceptStatus"] as? String
        
        switch acceptStatus {
        case "PENDING":
            if let boardIdStr = userInfo["boardId"] as? String, let boardId = Int(boardIdStr) {
                moveApplyDetailView(boardId: boardId)
            } else {
                LoggerService.shared.log(level: .error, "boardId 구할 수 없음")
            }
        case "ACCEPTED", nil:
            if let chatIdStr = userInfo["chatRoomId"] as? String, let chatId = Int(chatIdStr) {
                moveChatRoom(chatId: chatId)
            } else {
                moveChatRoom(chatId: nil)
            }
        default:
            LoggerService.shared.log(level: .error, "acceptStatus 구할 수 없음")
        }
        completionHandler()
    }
    private func moveApplyDetailView(boardId: Int) {
        // SceneDelegate의 rootViewController 가져오기
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
              let tabBarController = sceneDelegate.window?.rootViewController as? UITabBarController,
              let navigationController = tabBarController.selectedViewController as? UINavigationController else {
            return
        }
        // 이동
        let reactor = DIContainerService.shared.makeReciveMateReactor()
        let applyVC = ReceiveMateListViewController(reactor: reactor, id: String(boardId))
        navigationController.pushViewController(applyVC, animated: true)
    }
    
    private func moveChatRoom(chatId: Int?) {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
              let tabBarController = sceneDelegate.window?.rootViewController as? UITabBarController else {
            return
        }
        
        let targetTabIndex = 3
        guard targetTabIndex < (tabBarController.viewControllers?.count ?? 0) else {
            print("Invalid tab index.")
            return
        }
        
        tabBarController.selectedIndex = targetTabIndex
        
        // 탭 이동 후 NavigationController를 다시 가져오기 위해 async 사용
        DispatchQueue.main.async {
            guard let navigationController = tabBarController.selectedViewController as? UINavigationController else {
                print("탭 변경 후 NavigationController를 찾을 수 없음")
                return
            }
            
            guard let id = SetupInfoService.shared.getUserInfo(type: .id), let userId = Int(id) else {
                return
            }
            
            let chatInfoUC = DIContainerService.shared.makeChatDetailUseCase()
            if let chatId = chatId {
                chatInfoUC.loadChat(chatId)
                    .observe(on: MainScheduler.instance)
                    .subscribe { info in
                        let chatRoomVC = ChatRoomViewController(chat: ChatRoomInfo(chatRoomId: chatId, postInfo: info.postInfo, managerInfo: info.managerInfo, cheerTeam: info.postInfo.cheerTeam), userId: userId)
                        navigationController.pushViewController(chatRoomVC, animated: true)
                    }
                    .disposed(by: self.disposeBag) // self의 disposeBag 사용
            }
        }
    }
    
    // FCM 토큰 갱신 시 호출되는 메서드
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: ["token": fcmToken ?? ""])
    }
    
    // Remote Notification 수신 시 호출되는 메서드
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

