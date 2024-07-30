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

enum NaverLoginError: Error {
    case NotFountToken
    case serverError(code: Int, description: String)
    case decodingError
    case EmptyValue
    
    var statusCode: Int {
        switch self {
        case .NotFountToken:
            return -1001
        case .serverError(let code, _):
            return code
        case .decodingError:
            return -1002
        case .EmptyValue:
            return -1003
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .NotFountToken:
            return "토큰이 없습니다."
        case .serverError(_, let message):
            return "서버 에러: \(message)"
        case .decodingError:
            return "데이터 디코딩 에러"
        case .EmptyValue:
            return "빈 응답값 전달"
        }
    }
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
        loginInstance.requestThirdPartyLogin()
        return Observable.create { observer in
            self.naverLoginSubject = observer
            return Disposables.create()
        }
    }
    
    private func fetchUserDataWithValidToken() -> Observable<SNSLoginResponse> {
        guard let tokenType = loginInstance.tokenType,
              let accessToken = loginInstance.accessToken else {
            return Observable.error(NaverLoginError.NotFountToken)
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "\(tokenType) \(accessToken)"
        ]
        
        let url = "https://openapi.naver.com/v1/nid/me"
        
        return RxAlamofire.requestJSON(.get, url, headers: headers)
            .flatMap { (response, json) -> Observable<SNSLoginResponse> in
                guard let json = json as? [String: Any], let response = json["response"] as? [String: Any] else {
                    return Observable.error(NaverLoginError.decodingError)
                }
                print(json)
                print("==========================")
                print("response: \(response)")
                guard let id = response["id"] as? String else {
                    return Observable.error(NaverLoginError.EmptyValue)
                }
                guard let email = response["email"] as? String else {
                    return Observable.error(NaverLoginError.EmptyValue)
                }
//                let email = "ttang1135@naver.com"
                var birthResult: String? = nil
                if let birthday = response["birthday"] as? String,
                   let birthyear = response["birthyear"] as? String,
                   let birth = self.convertBirth(birthday: birthday, birthYear: birthyear) {
                    birthResult = birth
                }
                
                var genderResult: String? = nil
                let gender = response["gender"] as? String 
                if let nickname = response["nickname"] as? String {
                    return Observable.just(SNSLoginResponse(id: id, email: email, loginType: .naver, birth: birthResult, nickName: nickname, gender: genderResult))
                }
                return Observable.just(SNSLoginResponse(id: id, email: email, loginType: .naver, birth: birthResult, gender: genderResult))
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
        if let observer = naverLoginSubject {
            _ = fetchUserDataWithValidToken().subscribe(observer)
        }
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
