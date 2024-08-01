//
//  KakaoDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 7/27/24.
//

import UIKit
import RxSwift
import KakaoSDKCommon
import RxKakaoSDKCommon
import KakaoSDKAuth
import RxKakaoSDKAuth
import KakaoSDKUser
import RxKakaoSDKUser

protocol KakaoDataSource {
    func getKakaoLoginToken() -> Observable<SNSLoginResponse>
}

enum KakaoLoginError: LocalizedError {
    case kakaoLoginFailed
    case missingUserInfo
    case serverError(Int, String)
    
    var errorType: String {
        return String(describing: self)
    }
    
    var statusCode: Int {
        switch self {
        case .kakaoLoginFailed:
            return -1000
        case .missingUserInfo:
            return -1001
        case .serverError(let code, _):
            return code
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .kakaoLoginFailed:
            return "카카오 로그인 실패"
        case .missingUserInfo:
            return "UserInfo 얻기 실패"
        case .serverError(_, let string):
            return string
        }
    }
}

final class KakaoDataSourceImpl: NSObject, KakaoDataSource {
    private let disposeBag = DisposeBag()
    override init() {
        super.init()
    }
    
    func getKakaoLoginToken() -> Observable<SNSLoginResponse> {
        LoggerService.shared.debugLog("-------------KAKAO LOGIN------------------")
        return Observable.create { observer -> Disposable in
            // Check if KakaoTalk is available
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                    if let error = error {
                        LoggerService.shared.log("\(KakaoLoginError.errorType): \(error.statusCode) - \(error.localizedDescription)", level: .error)
                        observer.onError(KakaoLoginError.serverError(error.statusCode, error.localizedDescription))
                    } else {
                        guard let oauthToken = oauthToken else {
                            LoggerService.shared.log("\(KakaoLoginError.errorType): \(KakaoLoginError.kakaoLoginFailed.statusCode) - oauthToken 없음", level: .error)
                            observer.onError(KakaoLoginError.kakaoLoginFailed)
                            return
                        }
                        self?.fetchUserInfo(oauthToken: oauthToken.accessToken, observer: observer)
                    }
                }
            } else {
                // 웹뷰
                UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                    if let error = error {
                        LoggerService.shared.log("\(KakaoLoginError.errorType): \(error.statusCode) - \(error.localizedDescription)", level: .error)
                        observer.onError(KakaoLoginError.serverError(error.statusCode, error.localizedDescription))
                    } else {
                        guard let oauthToken = oauthToken else {
                            LoggerService.shared.log("\(KakaoLoginError.errorType): \(KakaoLoginError.kakaoLoginFailed) - oauthToken 없음", level: .error)
                            observer.onError(KakaoLoginError.kakaoLoginFailed)
                            return
                        }
                        self?.fetchUserInfo(oauthToken: oauthToken.accessToken, observer: observer)
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    private func fetchUserInfo(oauthToken: String, observer: AnyObserver<SNSLoginResponse>) {
        LoggerService.shared.debugLog("KAKAO Login - fetchUserInfo")
        UserApi.shared.me(propertyKeys: ["properties.nickname", "properties.profile_image", "kakao_account.email"]) { user, error in
            if let error = error {
                LoggerService.shared.log("\(KakaoLoginError.errorType): \(error.statusCode) - \(error.localizedDescription)", level: .error)
                observer.onError(KakaoLoginError.serverError(error.statusCode, error.localizedDescription))
            } else {
                guard let user = user, let id = user.id else {
                    LoggerService.shared.log("\(KakaoLoginError.errorType): \(KakaoLoginError.missingUserInfo.statusCode) - id를 찾을 수 없음", level: .error)
                    observer.onError(KakaoLoginError.missingUserInfo)
                    return
                }
                LoggerService.shared.log("\(user)")
                let email = user.kakaoAccount?.email ?? ""
                let nickName = user.properties?["nickname"] ?? ""
                let imageUrl = user.properties?["profile_image"] ?? ""
                
                let response = SNSLoginResponse(id: "\(id)", email: email, loginType: .kakao, birth: nil, nickName: nickName, gender: nil, image: imageUrl)
                LoggerService.shared.log("KakaoLogin Response : \(response)")
                observer.onNext(response)
                observer.onCompleted()
            }
        }
        
    }
}
    
