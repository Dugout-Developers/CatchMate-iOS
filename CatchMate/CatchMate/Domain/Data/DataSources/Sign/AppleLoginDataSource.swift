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

enum AppleLoginError: Error {
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
            print("APPLE Token: \(String(describing: appleIDCredential.identityToken))")
            let userId = appleIDCredential.user
            let response = SNSLoginResponse(id: userId, email: email, loginType: .apple)
            print("responseMapping:\(response)")
            print("============================")
            LoginUserDefaultsService.shared.setTempStorage(type: .apple, id: response.id, email: response.email)
            loginSubject.onNext(response)
            loginSubject.onCompleted()
        } else {
            if let loginData = LoginUserDefaultsService.shared.getLoginData() {
                if loginData.email.isEmpty {
                    loginSubject.onError(AppleLoginError.EmptyValue)
                }
                let response = SNSLoginResponse(id: loginData.id, email: loginData.email, loginType: .apple)
                print("UserDefaults:\(response)")
                print("============================")
                loginSubject.onNext(response)
                loginSubject.onCompleted()
            } else {
                loginSubject.onError(AppleLoginError.authorizationFailed)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        loginSubject.onError(error)
    }
}
