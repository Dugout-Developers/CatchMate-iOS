//
//  ProfileEditDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 12/13/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol ProfileEditDataSource {
    func editProfile(editModel: ProfileEditRequestDTO) -> Observable<ProfileEditResponseDTO>
}

final class ProfileEditDataSourceImpl: ProfileEditDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func editProfile(editModel: ProfileEditRequestDTO) -> Observable<ProfileEditResponseDTO> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        print(editModel)
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        let parameters: [String: Any] = [
            "nickName": editModel.nickname,
            "description": editModel.description,
            "favGudan": editModel.favGudan,
            "watchStyle": editModel.watchStyle
        ]
        
        return APIService.shared.requestAPI(type: .editProfile, parameters: parameters, headers: headers, encoding: JSONEncoding.default, dataType: ProfileEditResponseDTO.self)
            .map { dto in
                LoggerService.shared.debugLog("Profile Edit 성공: \(dto)")
                return dto
            }
            .catch { [weak self] error in
                guard let self else {
                    return Observable.error(ReferenceError.notFoundSelf)
                }
                if let error = error as? NetworkError, error.statusCode == 401 {
                    guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
                        return Observable.error(TokenError.notFoundRefreshToken)
                    }
                    return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
                        .flatMap { token -> Observable<ProfileEditResponseDTO> in
                            let newHeaders: HTTPHeaders = [
                                "AccessToken": token
                            ]
                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
                            return APIService.shared.requestAPI(type: .editProfile, parameters: parameters, headers: newHeaders, encoding: JSONEncoding.default, dataType: ProfileEditResponseDTO.self)
                                .map { dto in
                                    LoggerService.shared.debugLog("Profile Edit 성공: \(dto)")
                                    return dto
                                }
                        }
                        .catch { error in
                            return Observable.error(error)
                        }
                }
                return Observable.error(error)
            }
    }
}
