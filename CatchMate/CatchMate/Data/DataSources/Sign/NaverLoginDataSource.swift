//
//  NaverLoginDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 7/27/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire
import NaverThirdPartyLogin

protocol NaverLoginDataSource {
    func getNaverLoginToken() -> Observable<SNSLoginResponse>
}

final class NaverLoginDataSourceImpl: NSObject, NaverLoginDataSource, NaverThirdPartyLoginConnectionDelegate {
    private let disposeBag = DisposeBag()
    private let loginInstance: NaverThirdPartyLoginConnection
    override init() {
        self.loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
        super.init()
        self.loginInstance.delegate = self
    }
    
    private var naverLoginSubject: AnyObserver<SNSLoginResponse>?
    
    func getNaverLoginToken() -> Observable<SNSLoginResponse> {
        LoggerService.shared.log(level: .info, "네이버 로그인 요청")
        loginInstance.resetToken() // 로그아웃하여 토큰을 초기화
        loginInstance.requestThirdPartyLogin()
        return Observable.create { observer in
            self.naverLoginSubject = observer
            return Disposables.create()
        }
    }
    
    private func fetchUserDataWithValidToken() -> Observable<SNSLoginResponse> {
        guard let tokenType = loginInstance.tokenType,
              let accessToken = loginInstance.accessToken else {
            return Observable.error(SNSLoginError.authorizationFailed)
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "\(tokenType) \(accessToken)"
        ]
        
        let url = "https://openapi.naver.com/v1/nid/me"
        
        return RxAlamofire.requestJSON(.get, url, headers: headers)
            .flatMap { (response, json) -> Observable<SNSLoginResponse> in
                guard let json = json as? [String: Any], let response = json["response"] as? [String: Any] else {
                    LoggerService.shared.log(level: .debug, "NaverLoginError: 네이버 로그인 response - 디코딩 에러")
                    return Observable.error(CodableError.decodingFailed)
                }
                LoggerService.shared.log(level: .debug, "\(json)\n response: \(response)")
                guard let id = response["id"] as? String else {
                    LoggerService.shared.log(level: .debug, "NaverLoginError: id 응답값 찾을 수 없음")
                    return Observable.error(SNSLoginError.emptyValue(description: "NaverLogin - response[id]"))
                }
                guard let email = response["email"] as? String else {
                    LoggerService.shared.log(level: .debug, "NaverLoginError: email 값 없음")
                    return Observable.error(SNSLoginError.emptyValue(description: "NaverLogin - response[email]"))
                }
                var birthResult: String? = nil
                if let birthday = response["birthday"] as? String,
                   let birthyear = response["birthyear"] as? String,
                   let birth = self.convertBirth(birthday: birthday, birthYear: birthyear) {
                    birthResult = birth
                }
            
                let gender = response["gender"] as? String
                if let nickname = response["nickname"] as? String {
                    let model = SNSLoginResponse(id: id, email: email, loginType: .naver, birth: birthResult, nickName: nickname, gender: gender, image: response["profile_image"] as? String)
                    LoggerService.shared.log(level: .debug, "NAVER Response: \(model)")
                    LoginUserDefaultsService.shared.saveLoginData(email: model.email, loginType: .naver)
                    return Observable.just(model)
                }
                let model = SNSLoginResponse(id: id, email: email, loginType: .naver, birth: birthResult, gender: gender, image: response["profile_image"] as? String)
                LoggerService.shared.log(level: .info, "NAVER 로그인 요청 성공 - Response: \(model)")
                LoginUserDefaultsService.shared.saveLoginData(email: model.email, loginType: .naver)
                return Observable.just(model)
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
        if let observer = naverLoginSubject {
            _ = fetchUserDataWithValidToken().subscribe(observer)
        }
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        if let observer = naverLoginSubject {
            _ = fetchUserDataWithValidToken().subscribe(observer)
        }
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        print("Token Deleted")
    }
    
    func oauth20Connection(_ connection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("Error: \(error.localizedDescription)")
        LoggerService.shared.log(level: .debug, "NAVER API ERROR - \(error.localizedDescription)")
        if let observer = naverLoginSubject {
            observer.onError(SNSLoginError.loginServerError(message: error.localizedDescription))
        }
    }
    
}
