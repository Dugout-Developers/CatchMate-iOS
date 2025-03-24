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
        
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        return APIService.shared.performRequest(type: .receivedCount, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: RecivedCountResultDTO.self, refreshToken: refreshToken)
            .catch { error in
                LoggerService.shared.log(level: .debug, "받은 신청 카운트 load 실패 - \(error)")
                return Observable.error(error)
            }
    }
}

struct RecivedCountResultDTO: Codable {
    let newEnrollCount: Int
}
