//
//  MySendApplyDataSoure.swift
//  CatchMate
//
//  Created by 방유빈 on 9/2/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol SendAppiesDataSource {
    func loadSendApplies() -> Observable<[Content]>
    func loadSendAppliesIds() -> Observable<[Int]>
}


final class SendAppiesDataSourceImpl: SendAppiesDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    func loadSendApplies() -> RxSwift.Observable<[Content]> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        LoggerService.shared.log("토큰 확인: \(headers)")
        
        return APIService.shared.requestAPI(type: .sendApply, parameters: nil, headers: headers, dataType: ApplyListResponse.self)
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
                            return APIService.shared.requestAPI(type: .sendApply, parameters: nil, headers: newHeaders, dataType: ApplyListResponse.self)
                                .map { response -> [Content] in
                                    return response.content
                                }
                        }
                        .catch { error in
                            return Observable.error(error)
                        }
                }
                return Observable.error(error)
            }
    }
    
    func loadSendAppliesIds() -> RxSwift.Observable<[Int]> {
        return loadSendApplies()
            .map { contents -> [Int] in
                return contents.map { $0.enrollId }
            }
    }
    
    
}
