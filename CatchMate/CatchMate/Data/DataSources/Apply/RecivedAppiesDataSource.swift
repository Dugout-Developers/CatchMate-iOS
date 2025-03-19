//
//  RecivedAppiesDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 9/3/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol RecivedAppiesDataSource {
    func loadRecivedApplies(boardId: Int, page: Int) -> Observable<ReceivedAppliesDTO>
    func loadReceivedAppliesAll(_ page: Int) -> Observable<ReceivedAppliesDTO>
}

final class RecivedAppiesDataSourceImpl: RecivedAppiesDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadRecivedApplies(boardId: Int, page: Int) -> RxSwift.Observable<ReceivedAppliesDTO> {
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
            "boardId": boardId,
            "page": page
        ]
        
        return APIService.shared.performRequest(type: .receivedApply, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: ReceivedAppliesDTO.self, refreshToken: refreshToken)
            .map { response  in
                return response
            }
            .catch { error in
                LoggerService.shared.log(level: .debug, "\(boardId)번 게시물 받은 신청 load 실패 - \(error)")
                return Observable.error(error)
            }
    }
    
    func loadReceivedAppliesAll(_ page: Int) -> Observable<ReceivedAppliesDTO> {
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
        LoggerService.shared.log("토큰 확인: \(headers)")
        
        return APIService.shared.performRequest(type: .receivedApplyAll, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: ReceivedAppliesDTO.self, refreshToken: refreshToken)
            .map { response in
                return response
            }
            .catch { error in
                LoggerService.shared.log("받은 신청 전체 목록 load 실패 - \(error)")
                return Observable.error(error)
            }
    }
}
