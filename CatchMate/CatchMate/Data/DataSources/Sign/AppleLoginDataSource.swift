//
//  AppleLoginDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 7/27/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire
import AuthenticationServices

protocol AppleLoginDataSource {
    func getAppleLoginToken() -> Observable<SNSLoginResponse>
}

enum AppleLoginError: LocalizedError {
    case authorizationFailed
    case EmptyValue

    var statusCode: Int {
        switch self {
        case .authorizationFailed:
            return -1001
        case .EmptyValue:
            return -1003
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .authorizationFailed:
            return "권한 부여 실패"
        case .EmptyValue:
            return "빈 응답값 전달"
        }
    }
}
final class AppleLoginDataSourceImpl: NSObject, AppleLoginDataSource,  ASAuthorizationControllerDelegate {
    private let disposeBag = DisposeBag()
    override init() {
        super.init()
    }
    
    private var loginSubject = PublishSubject<SNSLoginResponse>()
    
    func getAppleLoginToken() -> Observable<SNSLoginResponse> {
        LoggerService.shared.debugLog("-------------APPLE LOGIN------------------")
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
        
        return loginSubject.asObservable()
    }
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let email = appleIDCredential.email {
            let userId = appleIDCredential.user
            let response = SNSLoginResponse(id: userId, email: email, loginType: .apple)
            LoggerService.shared.log("APPLE Login Response : \(response)")
            KeychainService.saveEmail(email: email, userIdentifier: userId)
            loginSubject.onNext(response)
        } else {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userId = appleIDCredential.user
                if let email = KeychainService.getEmail(userIdentifier: userId) {
                    if email.isEmpty {
                        LoggerService.shared.log("\(AppleLoginError.errorType) : \(AppleLoginError.EmptyValue.statusCode) - 이메일 없음", level: .error)
                        loginSubject.onError(AppleLoginError.EmptyValue)
                    }
                    let response = SNSLoginResponse(id: userId, email: email, loginType: .apple)
                    LoggerService.shared.log("APPLE Login Response(User Defaults) : \(response)")
                    loginSubject.onNext(response)
                } else {
                    LoggerService.shared.log("\(AppleLoginError.errorType) : \(AppleLoginError.authorizationFailed.statusCode) - \(AppleLoginError.authorizationFailed.errorDescription ?? "인증 실패")", level: .error)
                    loginSubject.onError(AppleLoginError.authorizationFailed)
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        LoggerService.shared.log("애플로그인 실패 : \(error)", level: .error)
        loginSubject.onError(error)
    }
}
