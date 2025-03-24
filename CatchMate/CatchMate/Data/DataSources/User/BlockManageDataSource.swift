//
//  BlockManageDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 2/17/25.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol BlockManageDataSource {
    func blockUser(userId: Int) -> Observable<Bool>
    func unblockUser(userId: Int) -> Observable<Bool>
}

final class BlockManageDataSourceImpl: BlockManageDataSource {
    private let tokenDataSource: TokenDataSource

    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func blockUser(userId: Int) -> Observable<Bool> {
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
        
        let addEndPoint = "\(userId)"
        
        return APIService.shared.performRequest(addEndPoint: addEndPoint, type: .blockUser, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: StateResponseDTO.self, refreshToken: refreshToken)
            .map { dto in
                LoggerService.shared.log("\(userId)번 유저 차단 성공: \(dto.state)")
                return dto.state
            }
            .catch { error in
                LoggerService.shared.log("유저 차단 실패: \(error)")
                return Observable.error(error)
            }
    }
    
    
    func unblockUser(userId: Int) -> Observable<Bool> {
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
        
        let addEndPoint = "\(userId)"
        
        return APIService.shared.performRequest(addEndPoint: addEndPoint, type: .unBlockUser, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: StateResponseDTO.self, refreshToken: refreshToken)
            .map { dto in
                LoggerService.shared.log("\(userId)번 유저 차단해제 성공: \(dto.state)")
                return dto.state
            }
            .catch { error in
                LoggerService.shared.log("유저 차단해제 실패: \(error)")
                return Observable.error(error)
            }
    }
}

