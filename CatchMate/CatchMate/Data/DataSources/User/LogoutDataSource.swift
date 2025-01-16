//
//  LogoutDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol LogoutDataSource {
    func logout() -> Observable<Bool>
    func deleteToken()
}

final class LogoutDataSourceImpl: LogoutDataSource {
    private let tokenDataSource: TokenDataSource
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    func logout() -> RxSwift.Observable<Bool> {
        LoggerService.shared.debugLog("--------------Logout--------------")
        
        guard let refeshToken = self.tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        
        let headers: HTTPHeaders = [
            "RefreshToken": refeshToken
        ]
        
        return APIService.shared.performRequest(type: .logout, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: StateResponseDTO.self, refreshToken: nil)
            .withUnretained(self)
            .map { ds, dto in
                if dto.state {
                    ds.deleteToken()
                }
                return dto.state
            }
            .catch { error in
                LoggerService.shared.debugLog("logout 실패 - \(error)")
                return Observable.just(true)
//                return Observable.error(error)
            }
    }
    
    func deleteToken() {
        let accessTokenDeleted = tokenDataSource.deleteToken(for: .accessToken)
        let refreshTokenDeleted = tokenDataSource.deleteToken(for: .refreshToken)
        
        LoggerService.shared.debugLog("AccessToken 삭제 status: \(accessTokenDeleted)")
        LoggerService.shared.debugLog("RefreshToken 삭제 status: \(refreshTokenDeleted)")
    }
}
