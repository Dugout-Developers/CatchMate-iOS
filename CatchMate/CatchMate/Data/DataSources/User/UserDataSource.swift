//
//  UserDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 7/30/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol UserDataSource {
    func loadMyInfo() -> Observable<UserDTO>
}

final class UserDataSourceImpl: UserDataSource {
    private let tokenDataSource: TokenDataSource

    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }

    
    func loadMyInfo() -> RxSwift.Observable<UserDTO> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            LoggerService.shared.log(level: .debug, "엑세스 토큰 찾기 실패")
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refreshToken = self.tokenDataSource.getToken(for: .refreshToken) else {
            LoggerService.shared.log(level: .debug, "리프레시 토큰 찾기 실패")
            return Observable.error(TokenError.notFoundRefreshToken)
        }

        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        return APIService.shared.performRequest(type: .loadMyInfo, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: UserDTO.self, refreshToken: refreshToken)
            .catch { error in
                LoggerService.shared.log(level: .debug, "내정보 load 실패 - \(error)")
                return Observable.error(error)
            }
    }
}
