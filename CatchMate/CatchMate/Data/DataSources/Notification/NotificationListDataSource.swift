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
    func loadNotificationList(_ page: Int) -> Observable<NotificationListResponse>
}

final class NotificationListDataSourceImpl: NotificationListDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadNotificationList(_ page: Int) -> RxSwift.Observable<NotificationListResponse> {
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
        let paramerters: [String: Any] = [
            "page": page
        ]
        return APIService.shared.performRequest(type: .notificationList, parameters: paramerters, headers: headers, encoding: URLEncoding.default, dataType: NotificationListResponse.self, refreshToken: refreshToken)
            .map { response in
                return response
            }
            .catch { error in
                LoggerService.shared.log("NotificationList Load 실패 - \(error)")
                return Observable.error(error)
            }
    }
}
