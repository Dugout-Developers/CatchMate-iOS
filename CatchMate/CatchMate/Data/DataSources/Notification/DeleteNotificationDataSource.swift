//
//  DeleteNotificationDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 1/8/25.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol DeleteNotificationDataSource {
    func deleteNotification(_ notificationId: Int) -> Observable<Bool>
}

final class DeleteNotificationDataSourceImpl: DeleteNotificationDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func deleteNotification(_ notificationId: Int) -> Observable<Bool> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        return APIService.shared.performRequest(addEndPoint: "\(notificationId)", type: .deleteNoti, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: StateResponseDTO.self, refreshToken: refreshToken)
            .map { dto in
                LoggerService.shared.debugLog("id: \(notificationId) - 알림 삭제 \(dto.state)")
                return dto.state
            }
            .catch { error in
                LoggerService.shared.debugLog("id: \(notificationId)번 알림 삭제 실패 - \(error)")
                return Observable.error(error)
            }
    }
}
