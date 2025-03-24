//
//  AppVersionService.swift
//  CatchMate
//
//  Created by 방유빈 on 2/25/25.
//
import Foundation
import FirebaseRemoteConfig
import Alamofire

final class AppVersionService {
    static let shared = AppVersionService()
    private let remoteConfig = RemoteConfig.remoteConfig()
    
    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 43200
        remoteConfig.configSettings = settings

        // 기본값 설정
        remoteConfig.setDefaults([
            "minimum_version": "1.0.0" as NSObject
        ])
    }
    
    func fetchRemoteConfig(completion: @escaping (String?) -> Void) {
        remoteConfig.fetchAndActivate { status, error in
            if let error = error {
                print("⚠️ Remote Config 가져오기 실패: \(error.localizedDescription)")
                completion(nil)
                return
            }
            let minimumVersion = self.remoteConfig["minimum_version"].stringValue ?? "1.0.0"
            completion(minimumVersion)
        }
    }
    
    func getCurrentAppVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    func isVersionNewer(currentVersion: String, minimumVersion: String) -> Bool {
        let currentComponents = currentVersion.split(separator: ".").map { Int($0) ?? 0 }
        let minimumComponents = minimumVersion.split(separator: ".").map { Int($0) ?? 0 }

        for (current, minimum) in zip(currentComponents, minimumComponents) {
            if current < minimum { return true }  // 현재 버전이 더 낮음 → 업데이트 필요
            if current > minimum { return false } // 현재 버전이 최신임 → 업데이트 불필요
        }

        return currentComponents.count < minimumComponents.count // 길이가 짧으면 오래된 버전
    }
}
