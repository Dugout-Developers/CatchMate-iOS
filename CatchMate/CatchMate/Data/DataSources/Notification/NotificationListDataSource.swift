//
//  NotificationListDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 10/8/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol NotificationListDataSource {
    func loadNotificationList() -> Observable<[NotificationDTO]>
}

final class NotificationListDataSourceImpl: NotificationListDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadNotificationList() -> RxSwift.Observable<[NotificationDTO]> {
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
        return APIService.shared.performRequest(type: .notificationList, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: NotificationListResponse.self, refreshToken: refreshToken)
            .map { response in
                return response.notificationInfoList
            }
            .catch { error in
                LoggerService.shared.log("NotificationList Load 실패 - \(error)")
                return Observable.error(error)
            }
    }
}
