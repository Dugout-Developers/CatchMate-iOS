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
        
        return APIService.shared.performRequest(addEndPoint: "\(notificationId)", type: .deleteNoti, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: StateResponseDTO.self, refreshToken: refreshToken)
            .map { dto in
                return dto.state
            }
            .catch { error in
                LoggerService.shared.log("id: \(notificationId)번 알림 삭제 실패 - \(error)")
                return Observable.error(error)
            }
    }
}
