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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
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

