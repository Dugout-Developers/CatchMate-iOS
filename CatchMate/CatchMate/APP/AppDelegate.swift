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

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let logPath = Bundle.main.logPath {
            LoggerService.shared.configure(logDirectoryPath: logPath)
        }
        // Auth Error 핸들러 의존성 주입
        UnauthorizedErrorHandler.shared.configure(logoutUseCase: DIContainerService.shared.makeLogoutUseCase())
        FirebaseApp.configure()
        // APNS 등록
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        
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
        // TODO: - 화면 이동userInfo에 들어있는 데이터를 바탕으로 특정 화면으로 이동
        let userInfo = notification.request.content.userInfo
        print("푸시 알림 수신 (foreground): \(userInfo)")
        completionHandler([.list, .banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("푸시 알림 수신 (background/terminated): \(userInfo)")
        
        if let boardIdStr = userInfo["boardId"] as? String, let boardId = Int(boardIdStr) {
            navigateApplyDetail(boardId: boardId)
        } else {
            print("boardId 구할 수 없음")
        }
        completionHandler()
    }
    
    func navigateApplyDetail(boardId: Int) {
        if let windowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first {
            
            // 윈도우가 있는지 확인
            if let window = windowScene.windows.first {
                print("윈도우 찾음: \(window)")
                
                // rootViewController가 있는지 확인
                if let rootViewController = window.rootViewController as? UINavigationController {
                    print("rootViewController 찾음: \(rootViewController)")
                    
                    // 상세 페이지로 이동
                    let reactor = DIContainerService.shared.makeReciveMateReactor()
                    reactor.action.onNext(.selectPost(String(boardId)))
                    let applyDetailVC = ReceiveMateListDetailViewController(reactor: reactor)
                    applyDetailVC.modalPresentationStyle = .overFullScreen
                    rootViewController.present(applyDetailVC, animated: false)
                } else {
                    print("rootViewController가 설정되지 않음")
                }
            } else {
                print("윈도우를 찾을 수 없음")
            }
        } else {
            print("UIWindowScene을 찾을 수 없음")
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

