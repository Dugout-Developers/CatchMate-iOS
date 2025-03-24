//
//  NotificationService.swift
//  CatchMate
//
//  Created by 방유빈 on 2/24/25.
//

import UserNotifications
import Alamofire
final class NotificationService {
    static let shared = NotificationService()

    private let tokenDS: TokenDataSource = TokenDataSourceImpl()
    private init() {}

    /// 알림 권한 요청 함수
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let hasRequestedBefore = UserDefaults.standard.object(forKey: UserDefaultsKeys.AlarmSetup.alarmSetup) != nil
        
        // 이미 요청한 적이 있다면 다시 요청하지 않음
        if hasRequestedBefore {
            checkNotificationPermissionStatus(completion: completion)
            return
        }
        
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("알림 권한 요청 오류: \(error.localizedDescription)")
                }
                completion(granted)
                UserDefaults.standard.setValue(granted, forKey: UserDefaultsKeys.AlarmSetup.alarmSetup)
                // 허용 시 서버로 전송
                self.sendNotificationPermissionToServer(granted)
            }
        }
    }

    /// 서버로 알림 허용 여부 전송
    func sendNotificationPermissionToServer(_ isAllow: Bool) {
        guard let base = Bundle.main.baseURL else {
            LoggerService.shared.log(level: .error, "Base URL 찾을 수 없음")
            return
        }
        let url = base+"/users/alarm"
        guard let token = tokenDS.getToken(for: .accessToken) else {
            LoggerService.shared.log(level: .error, "엑세스 토큰 찾기 실패")
            return
        }

        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        let parmeters: [String: Any] = [
            "alarmType": "ALL",
            "isEnabled": isAllow ? "Y" : "N"
        ]
        AF.request(url, method: .patch, parameters: parmeters, encoding: URLEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .response { response in
                switch response.result {
                case .success:
                    print("✅ 서버 전송 성공")
                case .failure(let error):
                    LoggerService.shared.errorLog(error, domain: "set_notification", message: "알림 권한 설정 서버 전송 실패")
                    print("❌ 서버 전송 실패: \(error.localizedDescription)")
                }
            }
    }

    /// 현재 알림 권한 상태 확인
    func checkNotificationPermissionStatus(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                let isAllowed = (settings.authorizationStatus == .authorized)
                completion(isAllowed)
            }
        }
    }
}
