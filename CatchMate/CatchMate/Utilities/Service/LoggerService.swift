//
//  LoggerService.swift
//  CatchMate
//
//  Created by 방유빈 on 8/1/24.
//

import Foundation
import FirebaseAnalytics
import FirebaseCrashlytics

enum LogLevel {
    case debug
    case info
    case warning
    case error

    var emoji: String {
        switch self {
        case .debug: return "[🐛 DEBUG]"
        case .info: return "[ℹ️ INFO]"
        case .warning: return "[⚠️ WARNING]"
        case .error: return "[❌ ERROR]"
        }
    }
}

class LoggerService {
    static let shared = LoggerService()

    func log(level: LogLevel = .debug, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let userId = SetupInfoService.shared.getUserInfo(type: .id)
        let userNickname = SetupInfoService.shared.getUserInfo(type: .nickName)
        let userEmail = SetupInfoService.shared.getUserInfo(type: .email)
        let info: [String: Any] = ["file": (file as NSString).lastPathComponent, "function": function, "line": line]
        // 로그 메시지 생성
        let logMessage = "\(level.emoji)\(function):\(line) - \(message)"

        #if DEBUG
        print(logMessage)
        #else
        if let userId = userId {
            Crashlytics.crashlytics().setUserID(userId)
            Analytics.setUserID(userId)
        }
        if let userNickname = userNickname {
            Crashlytics.crashlytics().setCustomValue(userNickname, forKey: "userNickname")
            Analytics.setUserProperty(userNickname, forName: "userNickname")
        }
        if let userEmail = userEmail {
            Crashlytics.crashlytics().setCustomValue(userEmail, forKey: "userEmail")
            Analytics.setUserProperty(userEmail, forName: "userEmail")
        }
        
        switch level {
        case .debug:
            break
        case .info:
            var parameters: [String: Any] = ["message": logMessage,
                                             "file": (file as NSString).lastPathComponent,
                                             "function": function,
                                             "line": line]
            if let userId = userId { parameters["userId"] = userId }
            if let userNickname = userNickname { parameters["userNickname"] = userNickname }
            if let userEmail = userEmail { parameters["userEmail"] = userEmail }
            
            Analytics.logEvent("info_log", parameters: parameters)
        case .warning:
            Crashlytics.crashlytics().log(logMessage)
        case .error:
            let error = NSError(domain: "com.catchmate.error", code: 1004, userInfo: [
                NSLocalizedDescriptionKey: message,
                "file": (file as NSString).lastPathComponent,
                "function": function,
                "line": line,
                "userId": userId ?? "unknown",
                "userNickname": userNickname ?? "unknown",
                "userEmail": userEmail ?? "unknown"
            ])
            Crashlytics.crashlytics().record(error: error)
        }
        #endif
    }
    
    func errorLog(_ error: Error, domain: String, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let errorTitle = "\(LogLevel.error.emoji) \(domain) Error 발생 - \(message)"
        let errorMessage = "message: \(message)"
        let info: [String: Any] = ["file": (file as NSString).lastPathComponent, "function": function, "line": line]
        print(errorTitle)
        print(errorMessage)
        print(error.localizedDescription)
        print("오류 코드 정보 :\n\(info)")
        #else
        let userId = SetupInfoService.shared.getUserInfo(type: .id) ?? "unknown"
        let userNickname = SetupInfoService.shared.getUserInfo(type: .nickName) ?? "unknown"
        let userEmail = SetupInfoService.shared.getUserInfo(type: .email) ?? "unknown"
        
        Crashlytics.crashlytics().setUserID(userId)
        Crashlytics.crashlytics().setCustomValue(userNickname, forKey: "userNickname")
        Crashlytics.crashlytics().setCustomValue(userEmail, forKey: "userEmail")
        
        var errorInfo: [String: Any] = [
            "userId": userId,
            "userNickname": userNickname,
            "userEmail": userEmail,
            "errorDescription": error.localizedDescription,
            "file": (file as NSString).lastPathComponent,  // 파일명만 저장
            "function": function,
            "line": line
        ]
        errorInfo["message"] = message
        
        if let customError = error as? DomainError {
            errorInfo["context"] = customError.context
        }
        
        let recodeError = NSError(domain: "com.catchmate.\(domain)", code: error.statusCode, userInfo: errorInfo)
        Crashlytics.crashlytics().record(error: recodeError)
        #endif
    }
}
