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
import NaverThirdPartyLogin
import RxAlamofire
import Alamofire

protocol SignDataSource {
    func getKakaoLoginToken() -> Observable<SNSLoginResponse>
    func getAppleLoginToken() -> Observable<SNSLoginResponse>
}

class SignDataSourceImpl: NSObject, SignDataSource, ASAuthorizationControllerDelegate, NaverThirdPartyLoginConnectionDelegate {
    
    private let loginInstance: NaverThirdPartyLoginConnection
    
    override init() {
        self.loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
        super.init()
        self.loginInstance.delegate = self
    }
    
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
    
    // MARK: - NAVER LOGIN
    private var naverLoginSubject: AnyObserver<SNSLoginResponse>?
    
    func getNaverLoginToken() -> Observable<SNSLoginResponse> {
        loginInstance.requestThirdPartyLogin()
        return Observable.create { observer in
            self.naverLoginSubject = observer
            return Disposables.create()
        }
    }
    
    private func fetchUserDataWithValidToken() -> Observable<SNSLoginResponse> {
        guard let tokenType = loginInstance.tokenType,
              let accessToken = loginInstance.accessToken else {
            return Observable.error(NSError(domain: "NaverAPI", code: 102, userInfo: [NSLocalizedDescriptionKey: "토큰이 없습니다."]))
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "\(tokenType) \(accessToken)"
        ]
        
        let url = "https://openapi.naver.com/v1/nid/me"
        
        return RxAlamofire.requestJSON(.get, url, headers: headers)
            .flatMap { (response, json) -> Observable<SNSLoginResponse> in
                guard let json = json as? [String: Any], let response = json["response"] as? [String: Any] else {
                    return Observable.error(NSError(domain: "NaverAPI", code: 103, userInfo: [NSLocalizedDescriptionKey: "응답 형식이 잘못되었습니다."]))
                }
                print("==========================")
                print("response: \(response)")
                guard let id = response["id"] as? String else {
                    return Observable.error(NSError(domain: "NaverAPI", code: 104, userInfo: [NSLocalizedDescriptionKey: "빈 응답 필드가 전달되었습니다."]))
                }
                var birthResult: String? = nil
                if let birthday = response["birthday"] as? String,
                   let birthyear = response["birthyear"] as? String,
                   let birth = self.convertBirth(birthday: birthday, birthYear: birthyear) {
                    birthResult = birth
                }
                
                var genderResult: String? = nil
                if let gender = response["gender"] as? String {
                    if gender == "F" { genderResult = "여성" }
                    else if gender == "M" { genderResult = "남성" }
                }
                if let nickname = response["nickname"] as? String {
                    return Observable.just(SNSLoginResponse(id: id, email: "naver\(id)", loginType: .naver, birth: birthResult, nickName: nickname, gender: genderResult))
                }
                return Observable.just(SNSLoginResponse(id: id, email: "naver\(id)", loginType: .naver, birth: birthResult, gender: genderResult))
            }
    }
    
    private func convertBirth(birthday: String, birthYear: String) -> String? {
        let yearSubstring = birthYear.suffix(2)
        guard let yearLastTwoDigits = Int(yearSubstring) else {
            return nil
        }
        let yearString = String(format: "%02d", yearLastTwoDigits)
        
        let components = birthday.split(separator: "-")
        guard components.count == 2,
              let month = Int(components[0]),
              let day = Int(components[1]) else {
            return nil
        }
        let monthDayString = String(format: "%02d%02d", month, day)

        return yearString + monthDayString
    }
    
    private func refreshAccessToken() -> Observable<Void> {
        return Observable.create { observer in
            self.loginInstance.requestAccessTokenWithRefreshToken()
            observer.onNext(())
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("Access Token Request Successful")
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print("Access Token Refresh Successful")
        if let observer = naverLoginSubject {
            _ = fetchUserDataWithValidToken().subscribe(observer)
        }
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        print("Token Deleted")
    }
    
    func oauth20Connection(_ connection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("Error: \(error.localizedDescription)")
        if let observer = naverLoginSubject {
            observer.onError(error)
        }
    }
}
