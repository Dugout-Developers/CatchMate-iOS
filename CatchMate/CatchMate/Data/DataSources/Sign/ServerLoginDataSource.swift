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
    func postLoginRequest(_ loginResponse: SNSLoginResponse, _ token: String) -> Observable<LoginResponse>
}

final class ServerLoginDataSourceImpl: ServerLoginDataSource {
    init() {}
    
    func postLoginRequest(_ loginResponse: SNSLoginResponse, _ token: String) -> Observable<LoginResponse> {
        LoggerService.shared.debugLog("-----------------Servser Request Login-------------------")
        let request = LoginMapper.snsToLoginRequest(loginResponse, token)
        LoggerService.shared.debugLog("RequestModel : \(request)")
        let parameters: [String: Any] = [
            "providerId": request.providerId,
            "provider": request.provider,
            "email": request.email,
            "picture": request.picture,
            "fcmToken": request.fcmToken
        ]
        
        return APIService.shared.requestAPI(type: .login, parameters: parameters, encoding: JSONEncoding.default, dataType: LoginResponse.self)
            .map { response in
                LoggerService.shared.debugLog("회원가입 성공: \(response)")
                return response
            }
            .catch { error in
                return Observable.error(error)
            }

    }
}
