//
//  ServerLoginDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 7/23/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol ServerLoginDataSource {
    func postLoginRequest(_ loginResponse: SNSLoginResponse, _ token: String) -> Observable<LoginModel>
}
enum ServerLoginError: Error {
    case notFountURL
    case serverError(code: Int, description: String)
    case decodingError
    
    
    var statusCode: Int {
        switch self {
        case .notFountURL:
            return -1001
        case .serverError(let code, _):
            return code
        case .decodingError:
            return -1002
            
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .notFountURL:
            return "서버 URL을 찾을 수 없습니다."
        case .serverError(_, let message):
            return "서버 에러: \(message)"
        case .decodingError:
            return "데이터 디코딩 에러"
            
            
        }
    }
}

final class ServerLoginDataSourceImpl: ServerLoginDataSource {
    init() {}
    
    func postLoginRequest(_ loginResponse: SNSLoginResponse, _ token: String) -> Observable<LoginModel> {
        guard let baseUrl = Bundle.main.baseURL else {
            return Observable.error(ServerLoginError.notFountURL)
        }
        let url = "\(baseUrl)/auth/login"
        print(url)
        let request = LoginMapper.snsToLoginRequest(loginResponse, token)
        print(request)
        let parameters: [String: Any] = [
            "provideId": request.provideId,
            "provider": request.provider,
            "email": request.email,
            "picture": request.picture ?? "",
            "fcmToken": request.fcmToken
        ]
        print(parameters)
        return RxAlamofire.requestData(.post, url, parameters: parameters, encoding: JSONEncoding.default)
            .flatMap { (response, data) -> Observable<LoginResponse> in
                guard 200..<300 ~= response.statusCode else {
                    print(response.statusCode)
                    print(response.description)
                    print(response.debugDescription)
                    if let errorData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = errorData["errorMessage"] as? String {
                        print(errorMessage)
                    }
                    return Observable.error(ServerLoginError.serverError(code: response.statusCode, description: "서버에러 발생"))
                }
                do {
                    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    return Observable.just(loginResponse)
                } catch {
                    return Observable.error(ServerLoginError.decodingError)
                }
            }
            .flatMap { response -> Observable<LoginModel> in
                let model = LoginModel(id: loginResponse.id, email: loginResponse.email, accessToken: response.accessToken, refreshToken: response.refreshToken, isFirstLogin: response.isFirstLogin, nickName: loginResponse.nickName, gender: Gender(rawValue: loginResponse.gender ?? ""), birth: loginResponse.birth, profileImage: loginResponse.imageUrl)
                return Observable.just(model)
            }
    }
}
