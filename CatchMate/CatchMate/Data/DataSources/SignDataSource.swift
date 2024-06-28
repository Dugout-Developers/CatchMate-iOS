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
                    print("============================")
                    print("얍\(String(describing: oauthToken))")
                    // 사용자 정보 요청
                    UserApi.shared.me { (user, error) in
                        if let error = error {
                            observer.onError(error)
                        } else if let user = user {
                            // 필요한 정보를 KakaoLoginResponse로 변환하여 observer에 전달
                            print("user:\(user)")
                            print("============================")
                            let response = SNSLoginResponse(id: "\(String(describing: user.id))",
                                                              name: user.kakaoAccount?.profile?.nickname ?? "",
                                                              email: user.kakaoAccount?.email ?? "")
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

    func getAppleLoginToken() -> RxSwift.Observable<SNSLoginResponse> {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
        
        return loginSubject.asObservable()
    }
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            print("APPLE Token: \(String(describing: appleIDCredential.identityToken))")
            let userId = appleIDCredential.user
            let fullName = appleIDCredential.fullName?.givenName ?? ""
            let email = appleIDCredential.email ?? ""
            let response = SNSLoginResponse(id: userId, name: fullName, email: email)
            print("responseMapping:\(response)")
            print("============================")
            loginSubject.onNext(response)
            loginSubject.onCompleted()
        } else {
            loginSubject.onError(NSError(domain: "AppleLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "Authorization failed"]))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        loginSubject.onError(error)
    }

}
