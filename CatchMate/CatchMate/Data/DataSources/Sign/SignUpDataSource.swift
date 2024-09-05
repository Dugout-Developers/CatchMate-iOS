//
//  SignUpDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 7/23/24.
//

import RxSwift
import RxAlamofire
import Alamofire
import UIKit

protocol SignUpDataSource {
    func saveUserModel(_ model: SignUpRequest) -> Observable<SignUpResponseDTO>
}


final class SignUpDataSourceImpl: SignUpDataSource {
    private let tokenDataSource: TokenDataSource
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    func saveUserModel(_ model: SignUpRequest) -> Observable<SignUpResponseDTO> {
        LoggerService.shared.debugLog("-----------------Servser Request SignUp-------------------")
        
        var parameters: [String: Any] = [
            "email": model.email,
            "provider": model.provider,
            "providerId": model.providerId,
            "gender": model.gender,
            "picture": model.picture ?? "",
            "fcmToken": model.fcmToken,
            "nickName": model.nickName,
            "birthDate": model.birthDate,
            "favGudan": model.favGudan
        ]
        
        if let watchStyle = model.watchStyle {
            parameters["watchStyle"] = watchStyle
        }
        LoggerService.shared.debugLog("SignUp Parameters : \(parameters)")
        return APIService.shared.requestAPI(type: .signUp, parameters: parameters, encoding: JSONEncoding.default, dataType: SignUpResponseDTO.self)
            .withUnretained(self)
            .flatMap { ds, dto -> Observable<SignUpResponseDTO> in
                LoggerService.shared.debugLog("회원가입 성공: \(dto)")
                
                // AccessToken 및 RefreshToken 저장
                let accessTokenSaved = ds.tokenDataSource.saveToken(token: dto.accessToken, for: .accessToken)
                let refreshTokenSaved = ds.tokenDataSource.saveToken(token: dto.refreshToken, for: .refreshToken)
                
                // 토큰 저장 실패 시 에러 발생
                if !accessTokenSaved || !refreshTokenSaved {
                    LoggerService.shared.debugLog("토큰 저장 실패")
                    return Observable.error(TokenError.failureTokenService)
                }
                
                return Observable.just(dto)
            }
            .catch { error in
                return Observable.error(error)
            }
        
    }
}



