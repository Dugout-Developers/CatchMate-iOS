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
        LoggerService.shared.log(level: .info, "회원가입 요청")
        
        let parameters: [String: Any] = [
            "email": model.email,
            "provider": model.provider,
            "providerId": model.providerId,
            "gender": model.gender,
            "profileImageUrl": model.profileImageUrl ?? "",
            "fcmToken": model.fcmToken,
            "nickName": model.nickName,
            "birthDate": model.birthDate,
            "favoriteClubId": model.favoriteClubId,
            "watchStyle": model.watchStyle ?? ""
        ]
         
        LoggerService.shared.log(level: .debug, "SignUp Parameters : \(parameters)")
        return APIService.shared.performRequest(type: .signUp, parameters: parameters, headers: nil, encoding: JSONEncoding.default, dataType: SignUpResponseDTO.self, refreshToken: nil)
            .withUnretained(self)
            .flatMap { ds, dto -> Observable<SignUpResponseDTO> in
                // AccessToken 및 RefreshToken 저장
                let accessTokenSaved = ds.tokenDataSource.saveToken(token: dto.accessToken, for: .accessToken)
                let refreshTokenSaved = ds.tokenDataSource.saveToken(token: dto.refreshToken, for: .refreshToken)
                
                // 토큰 저장 실패 시 에러 발생
                if !accessTokenSaved || !refreshTokenSaved {
                    LoggerService.shared.log(level: .debug, "토큰 저장 실패")
                    return Observable.error(TokenError.failureTokenService)
                }
                LoggerService.shared.log(level: .info, "회원가입 성공: \(dto)")
                return Observable.just(dto)
            }
            .catch { error in
                LoggerService.shared.log(level: .debug, "SignUp API 호출 실패 - \(error)")
                return Observable.error(error)
            }
    }
}



