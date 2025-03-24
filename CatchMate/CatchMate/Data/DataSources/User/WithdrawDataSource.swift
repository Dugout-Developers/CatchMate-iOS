//
//  WithdrawDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 3/6/25.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol WithdrawDataSource {
    func withdraw() -> Observable<Bool>
}

final class WithdrawDataSourceImpl: WithdrawDataSource {
    private let tokenDataSource: TokenDataSource
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func withdraw() -> Observable<Bool> {
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
        
        return APIService.shared.performRequest(type: .withdraw, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: StateResponseDTO.self, refreshToken: refreshToken)
            .withUnretained(self)
            .map { ds, dto in
                _ = ds.tokenDataSource.deleteToken(for: .accessToken)
                _ = ds.tokenDataSource.deleteToken(for: .refreshToken)
                LoggerService.shared.log("유저 탈퇴 요청 성공 결과: \(dto.state)")
                return dto.state
            }
            .catch { error in
                LoggerService.shared.log("유저 탈퇴 실패: \(error)")
                return Observable.error(error)
            }
    }
}
