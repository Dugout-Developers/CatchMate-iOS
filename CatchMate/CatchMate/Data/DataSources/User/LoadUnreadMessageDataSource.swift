//
//  LoadUnreadMessageDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 3/13/25.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

struct UnreadMessageDTO: Codable {
    let hasUnreadChat: Bool
    let hasUnreadNotification: Bool
}
protocol LoadUnreadMessageDataSource {
    func loadUnreadMessage() -> Observable<UnreadMessageDTO>
}

final class LoadUnreadMessageDataSourceImpl: LoadUnreadMessageDataSource {
    private let tokenDataSource: TokenDataSource
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }

    func loadUnreadMessage() -> RxSwift.Observable<UnreadMessageDTO> {
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
        
        return  APIService.shared.performRequest(type: .unreadMessage, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: UnreadMessageDTO.self, refreshToken: refreshToken)
            .do { dto in
                LoggerService.shared.log("UnreadMessage DTO: \(dto)")
            }
            .catch { error in
                LoggerService.shared.log("안읽은 알림 여부 조회 실패: \(error)")
                return Observable.error(error)
            }
    }
    
    
}
