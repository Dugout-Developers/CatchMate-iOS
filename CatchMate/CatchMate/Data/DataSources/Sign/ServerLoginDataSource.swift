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

final class ServerLoginDataSourceImpl: ServerLoginDataSource {
    init() {}
    
    func postLoginRequest(_ loginResponse: SNSLoginResponse, _ token: String) -> Observable<LoginModel> {
        LoggerService.shared.debugLog("-----------------Servser Request Login-------------------")
        guard let baseUrl = Bundle.main.baseURL else {
            return Observable.error(NetworkError.notFoundBaseURL)
        }
        let url = "\(baseUrl)/auth/login"
        LoggerService.shared.log("\(url) post 요청")
        let request = LoginMapper.snsToLoginRequest(loginResponse, token)
        LoggerService.shared.debugLog("RequestModel : \(request)")
        let parameters: [String: Any] = [
            "providerId": request.providerId,
            "provider": request.provider,
            "email": request.email,
            "picture": request.picture,
            "fcmToken": request.fcmToken
        ]

        return RxAlamofire.requestData(.post, url, parameters: parameters, encoding: JSONEncoding.default)
            .flatMap { (response, data) -> Observable<LoginResponse> in
                guard 200..<300 ~= response.statusCode else {
                    LoggerService.shared.debugLog("요청 Error : \(response.statusCode) \(response.debugDescription)")
                    if let errorData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = errorData["errorMessage"] as? String {
                        print(errorMessage)
                    }
                    if 400..<500 ~= response.statusCode {
                        return Observable.error(NetworkError.clientError(statusCode: response.statusCode))
                    } else if 500..<600 ~= response.statusCode {
                        return Observable.error(NetworkError.serverError(statusCode: response.statusCode))
                    } else {
                        return Observable.error(NetworkError.unownedError(statusCode: response.statusCode))
                    }
                }
                do {
                    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    LoggerService.shared.debugLog("Server Login Response: \(loginResponse)")
                    return Observable.just(loginResponse)
                } catch {
                    LoggerService.shared.log("ServerLogin Response Decoding 실패: - \(CodableError.decodingFailed.errorDescription ?? "디코딩 에러")", level: .error)
                    return Observable.error(CodableError.decodingFailed)
                }
            }
            .flatMap { response -> Observable<LoginModel> in
                let model = LoginModel(id: loginResponse.id, email: loginResponse.email, accessToken: response.accessToken, refreshToken: response.refreshToken, isFirstLogin: response.isFirstLogin, nickName: loginResponse.nickName, gender: Gender(rawValue: loginResponse.gender ?? ""), birth: loginResponse.birth, profileImage: loginResponse.imageUrl)
                LoggerService.shared.debugLog("To Presentation : \(model)")
                return Observable.just(model)
            }
    }
}
