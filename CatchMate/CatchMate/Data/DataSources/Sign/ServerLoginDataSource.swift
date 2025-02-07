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
    private let tokenDataSource: TokenDataSource
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func postLoginRequest(_ loginResponse: SNSLoginResponse, _ token: String) -> Observable<LoginResponse> {
        LoggerService.shared.log(level: .info, "로그인 서버 요청")
        let request = LoginMapper.snsToLoginRequest(loginResponse, token)
        LoggerService.shared.log(level: .debug, "RequestModel : \(request)")
        
        let parameters: [String: Any] = [
            "providerId": request.providerId,
            "provider": request.provider,
            "email": request.email,
            "picture": request.picture,
            "fcmToken": request.fcmToken
        ]
        
        return APIService.shared.requestAPI(type: .login, parameters: parameters, encoding: JSONEncoding.default, dataType: LoginResponse.self)
            .withUnretained(self)
            .flatMap { ds, dto -> Observable<LoginResponse> in
                LoggerService.shared.log(level: .info, "로그인 요청 성공: \(dto)")
                
                if let accessToken = dto.accessToken, let refreshToken = dto.refreshToken {
                    // AccessToken 및 RefreshToken 저장
                    let accessTokenSaved = ds.tokenDataSource.saveToken(token: accessToken, for: .accessToken)
                    let refreshTokenSaved = ds.tokenDataSource.saveToken(token: refreshToken, for: .refreshToken)
                    
                    // 토큰 저장 실패 시 에러 발생
                    if !accessTokenSaved || !refreshTokenSaved {
                        LoggerService.shared.log(level: .debug, "로그인 요청 이후 - 토큰 저장 실패")
                        return Observable.error(TokenError.failureTokenService)
                    }
                }
                
                return Observable.just(dto)
            }
            .catch { error in
                return Observable.error(error)
            }
    }
}
