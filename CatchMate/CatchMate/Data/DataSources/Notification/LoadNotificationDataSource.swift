//
//  LoadNotificationDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 3/9/25.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol LoadNotificationDataSource {
    func loadNotification(_ id: Int) -> Observable<NotificationDTO>
}

final class LoadNotificationDataSourceImpl: LoadNotificationDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadNotification(_ id: Int) -> RxSwift.Observable<NotificationDTO> {
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
     
        return APIService.shared.performRequest(addEndPoint: "\(id)", type: .notification, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: NotificationDTO.self, refreshToken: refreshToken)
            .map { response in
                return response
            }
            .catch { error in
                LoggerService.shared.log("Notification Load 실패 - \(error)")
                return Observable.error(error)
            }
    }
}
