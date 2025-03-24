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

final class AppleLoginDataSourceImpl: NSObject, AppleLoginDataSource,  ASAuthorizationControllerDelegate {
    private let disposeBag = DisposeBag()
    override init() {
        super.init()
    }
    
    private var loginSubject = PublishSubject<SNSLoginResponse>()
    
    func getAppleLoginToken() -> Observable<SNSLoginResponse> {
        LoggerService.shared.log(level: .debug, "애플로그인 요청")
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
            LoggerService.shared.log(level: .info, "APPLE Login Response : \(response)")
            saveEmail(email: email, userIdentifier: userId)
            loginSubject.onNext(response)
        } else {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userId = appleIDCredential.user
                if let email = getEmail(userIdentifier: userId) {
                    if email.isEmpty {
                        LoggerService.shared.log(level: .debug, "이메일 값 찾기 실패")
                        loginSubject.onError(SNSLoginError.emptyValue(description: "Apple Login - email값"))
                    }
                    let response = SNSLoginResponse(id: userId, email: email, loginType: .apple)
                    LoggerService.shared.log(level: .debug, "APPLE Login Response(User Defaults) : \(response)")
                    loginSubject.onNext(response)
                } else {
                    LoggerService.shared.log(level: .debug, "인증 실패")
                    loginSubject.onError(SNSLoginError.authorizationFailed)
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        LoggerService.shared.log(level: .debug, "애플로그인 실패 : \(error)")
        loginSubject.onError(error)
    }
    
    // MARK: - Appple Email 관련
    // 이메일 저장
    @discardableResult
    func saveEmail(email: String, userIdentifier: String) -> Bool {
        let data = email.data(using: .utf8)!
        
        let account = "email_\(userIdentifier)"
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: account
            ]
            let updateAttributes: [String: Any] = [
                kSecValueData as String: data
            ]
            SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
        }
        
        return status == errSecSuccess || status == errSecDuplicateItem
    }
    
    // 이메일 불러오기
    func getEmail(userIdentifier: String) -> String? {
        let account = "email_\(userIdentifier)"
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                return String(data: retrievedData, encoding: .utf8)
            }
        }
        
        return nil
    }

}
