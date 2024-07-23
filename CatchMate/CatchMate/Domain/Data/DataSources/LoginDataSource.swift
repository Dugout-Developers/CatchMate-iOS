//
//  LoginDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 7/23/24.
//

import UIKit
import RxSwift
import RxAlamofire

protocol LoginDataSource {
    func postLoginRequest(_ loginResponse: SNSLoginResponse, _ token: String) -> Observable<LoginModel>
}

final class LoginDataSourceImpl: LoginDataSource {
    private let baseUrl: String
    
    init() throws {
        guard let baseUrl = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else {
            throw NSError(domain: "ConfigError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Base URL not found in Info.plist"])
        }
        self.baseUrl = baseUrl
    }
    func postLoginRequest(_ loginResponse: SNSLoginResponse, _ token: String) -> Observable<LoginModel> {
        let url = "\(baseUrl)/login"
        let request = LoginMapper.snsToLoginRequest(loginResponse, token)
        let parameters: [String: Any] = [
            "provideId": request.provideId,
            "provider": request.provider,
            "email": request.email,
            "picture": request.picture ?? "",
            "fcmToken": request.fcmToken
        ]
        return RxAlamofire.requestData(.post, url, parameters: parameters)
            .flatMap { (response, data) -> Observable<LoginResponse> in
                guard 200..<300 ~= response.statusCode else {
                    return Observable.error(NSError(domain: "LoginError", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"]))
                }
                do {
                    // JSON 데이터를 User 객체로 디코딩
                    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    return Observable.just(loginResponse)
                } catch {
                    // 디코딩 중 에러 발생 시 에러 반환
                    return Observable.error(error)
                }
            }
            .flatMap { response -> Observable<LoginModel> in
                let model = LoginModel(id: loginResponse.id, email: loginResponse.email, accessToken: response.accessToken, refreshToken: response.refreshToken, isFirstLogin: response.isFirstLogin, nickName: loginResponse.nickName, gender: Gender(rawValue: loginResponse.gender ?? ""), birth: loginResponse.birth, profileImage: loginResponse.imageUrl)
                return Observable.just(model)
            }
    }
}
