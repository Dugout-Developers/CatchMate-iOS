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
    func loadRecivedApplies(boardId: Int) -> Observable<[Content]>
    func loadReceivedAppliesAll() -> Observable<[Content]>
}

final class RecivedAppiesDataSourceImpl: RecivedAppiesDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadRecivedApplies(boardId: Int) -> RxSwift.Observable<[Content]> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        let parameters: [String: Any] = [
            "boardId": boardId
        ]
        LoggerService.shared.log("토큰 확인: \(headers)")
        
        return APIService.shared.performRequest(type: .receivedApply, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: ApplyListResponse.self, refreshToken: refreshToken)
            .map { response -> [Content] in
                return response.enrollInfoList
            }
            .catch { error in
                LoggerService.shared.debugLog("\(boardId)번 게시물 받은 신청 load 실패 - \(error)")
                return Observable.error(error)
            }
    }
    
    func loadReceivedAppliesAll() -> Observable<[Content]> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        LoggerService.shared.log("토큰 확인: \(headers)")
        
        return APIService.shared.performRequest(type: .receivedApplyAll, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: ApplyListResponse.self, refreshToken: refreshToken)
            .map { response -> [Content] in
                return response.enrollInfoList
            }
            .catch { error in
                LoggerService.shared.debugLog("받은 신청 전체 목록 load 실패 - \(error)")
                return Observable.error(error)
            }
    }
}
