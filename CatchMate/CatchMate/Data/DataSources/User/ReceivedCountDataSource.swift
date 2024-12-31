//
//  ReceivedCountDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 11/12/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol ReceivedCountDataSource {
    func getReceivedCount() -> Observable<RecivedCountResultDTO>
}

final class RecivedCountDataSourceImpl: ReceivedCountDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    
    func getReceivedCount() -> Observable<RecivedCountResultDTO> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        return APIService.shared.requestAPI(type: .receivedCount, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: RecivedCountResultDTO.self)
            .map { dto in
                LoggerService.shared.debugLog("Count Load 성공: \(dto)")
                return dto
            }
            .catch { [weak self] error in
                guard let self else {
                    return Observable.error(OtherError.notFoundSelf)
                }
                if let error = error as? NetworkError, error.statusCode == 401 {
                    guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
                        return Observable.error(TokenError.notFoundRefreshToken)
                    }
                    return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
                        .flatMap { token -> Observable<RecivedCountResultDTO> in
                            let newHeaders: HTTPHeaders = [
                                "AccessToken": token
                            ]
                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
                            return APIService.shared.requestAPI(type: .receivedCount, parameters: nil, headers: newHeaders, encoding: URLEncoding.default, dataType: RecivedCountResultDTO.self)
                                .map { dto in
                                    LoggerService.shared.debugLog("Count Load 성공: \(dto)")
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

struct RecivedCountResultDTO: Codable {
    let newEnrollCount: Int
}
