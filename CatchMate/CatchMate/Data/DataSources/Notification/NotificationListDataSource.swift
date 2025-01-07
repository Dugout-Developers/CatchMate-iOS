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
            return Observable.error(TokenError.notFoundAccessToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        return APIService.shared.requestAPI(type: .notificationList, parameters: nil, headers: headers, encoding: JSONEncoding.default, dataType: NotificationListResponse.self)
            .map { response in
                LoggerService.shared.debugLog("NotificationList Load 성공: \(response)")
                return response.notificationInfoList
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.error(OtherError.notFoundSelf) }
                if let error = error as? NetworkError, error.statusCode == 401 {
                    guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
                        return Observable.error(TokenError.notFoundRefreshToken)
                    }
                    
                    return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
                        .flatMap { token -> Observable<[NotificationDTO]> in
                            let newHeaders: HTTPHeaders = [
                                "AccessToken": token
                            ]
                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
                            
                            return APIService.shared.requestAPI(type: .notificationList, parameters: nil, headers: newHeaders, encoding: JSONEncoding.default, dataType: NotificationListResponse.self)
                                .map { response in
                                    LoggerService.shared.debugLog("NotificationList Load 성공: \(response)")
                                    return response.notificationInfoList
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
