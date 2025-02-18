//
//  LoadBlockUsersDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 2/17/25.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol LoadBlockUsersDataSource {
    func loadBlockUsers(page: Int) -> Observable<BlockUserInfoDTO>
}

final class LoadBlockUsersDataSourceImpl: LoadBlockUsersDataSource {
    private let tokenDataSource: TokenDataSource

    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadBlockUsers(page: Int) -> RxSwift.Observable<BlockUserInfoDTO> {
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
        
        let parameters: [String: Any] = [
            "page": page
        ]
        
        return APIService.shared.performRequest(type: .blockUserList, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: BlockUserInfoDTO.self, refreshToken: refreshToken)
            .do { dto in
                LoggerService.shared.log("차단 유저 DTO: \(dto)")
            }
            .catch { error in
                LoggerService.shared.log("차단유저 조회 실패: \(error)")
                return Observable.error(error)
            }
    }
    
    
}
