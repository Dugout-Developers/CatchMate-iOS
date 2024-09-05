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
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        let parameters: [String: Any] = [
            "boardId": boardId
        ]
        LoggerService.shared.log("토큰 확인: \(headers)")
        
        return APIService.shared.requestAPI(type: .receivedApply, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: ApplyListResponse.self)
            .map { response -> [Content] in
                return response.content
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.error(ReferenceError.notFoundSelf) }
                if error.statusCode == 401 {
                    guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
                        return Observable.error(TokenError.notFoundRefreshToken)
                    }
                    return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
                        .flatMap { token -> Observable<[Content]> in
                            let newHeaders: HTTPHeaders = [
                                "AccessToken": token
                            ]
                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
                            return APIService.shared.requestAPI(type: .receivedApply, parameters: parameters, headers: newHeaders, encoding: URLEncoding.default, dataType: ApplyListResponse.self)
                                .map { response -> [Content] in
                                    return response.content
                                }
                        }
                }
                return Observable.error(error)
            }
    }
    
    
}
