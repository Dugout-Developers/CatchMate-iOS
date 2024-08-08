//
//  LoginUserDefaultsService.swift
//  CatchMate
//
//  Created by 방유빈 on 8/7/24.
//

import UIKit
import RxSwift

struct LoginData {
    let email: String
    let loginTypeImageName: String
}

final class LoginUserDefaultsService {
    enum LoginUserDataKeys: String {
        case email
        case loginTypeImage
    }
    
    enum LoginDataError: LocalizedError {
        case noLoginData
        
        var statusCode: Int {
            switch self {
            case .noLoginData:
                return -9000
            }
        }
        
        var errorDescription: String? {
            switch self {
            case .noLoginData:
                return "저장된 로그인 데이터가 없음. 재로그인 시도 필요"
            }
        }
    }

    static let shared = LoginUserDefaultsService()
    
    func saveLoginData(email: String, loginType: LoginType) {
        LoggerService.shared.log("UserData 저장: \(email), \(loginType.rawValue)")
        UserDefaults.standard.setValue(email, forKey: LoginUserDataKeys.email.rawValue)
        switch loginType {
        case .kakao:
            UserDefaults.standard.setValue("kakaoLogo", forKey: LoginUserDataKeys.loginTypeImage.rawValue)
        case .naver:
            UserDefaults.standard.setValue("naverLogo", forKey: LoginUserDataKeys.loginTypeImage.rawValue)
        case .apple:
            UserDefaults.standard.setValue("appleLogo", forKey: LoginUserDataKeys.loginTypeImage.rawValue)
        }
    }
    
    func deleteLoginData() {
        LoggerService.shared.log("UserData 삭제")
        UserDefaults.standard.removeObject(forKey: LoginUserDataKeys.email.rawValue)
        UserDefaults.standard.removeObject(forKey: LoginUserDataKeys.loginTypeImage.rawValue)
    }
    
    func getLoginData() -> Observable<LoginData> {
        Observable.create { observer in
            if let email = UserDefaults.standard.string(forKey: LoginUserDataKeys.email.rawValue), let imageName = UserDefaults.standard.string(forKey: LoginUserDataKeys.loginTypeImage.rawValue) {
                observer.onNext(LoginData(email: email, loginTypeImageName: imageName))
                observer.onCompleted()
            } else {
                observer.onError(LoginDataError.noLoginData)
            }
            return Disposables.create()
        }
    }
}
