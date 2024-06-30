//
//  SignDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import UIKit
import RxSwift
import RxKakaoSDKCommon
import RxKakaoSDKUser
import KakaoSDKUser
import AuthenticationServices

protocol SignDataSource {
    func getKakaoLoginToken() -> Observable<SNSLoginResponse>
    func getAppleLoginToken() -> Observable<SNSLoginResponse>
}

class SignDataSourceImpl: NSObject, SignDataSource, ASAuthorizationControllerDelegate {
    
    // MARK: - KAKAO LOGIN
    func getKakaoLoginToken() -> Observable<SNSLoginResponse> {
        return Observable.create { observer in
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    observer.onError(error)
                } else if oauthToken != nil {
                    print("Token : \(String(describing: oauthToken))")
                    // 사용자 정보 요청
                    UserApi.shared.me { (user, error) in
                        if let error = error {
                            observer.onError(error)
                        } else if let user = user {
                            print("User: \(user)")
                            print("============================")
                            // 필요한 정보를 KakaoLoginResponse로 변환하여 observer에 전달
                            guard let userid = user.id else {
                                return
                            }
                            let email = user.kakaoAccount?.email ?? "kakao" + String(userid)
                            let response = SNSLoginResponse(id: String(userid), email: email, loginType: .kakao)
                            observer.onNext(response)
                            observer.onCompleted()
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    // MARK: - APPLE LOGIN
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
                let response = SNSLoginResponse(id: loginData.id, email: loginData.email, loginType: .apple)
                print("UserDefaults:\(response)")
                print("============================")
                loginSubject.onNext(response)
                loginSubject.onCompleted()
            } else {
                loginSubject.onError(NSError(domain: "AppleLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "Authorization failed"]))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        loginSubject.onError(error)
    }

}
