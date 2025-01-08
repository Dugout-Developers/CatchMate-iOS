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
        
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        return APIService.shared.requestAPI(addEndPoint: "\(notificationId)", type: .deleteNoti, parameters: nil, headers: headers, encoding: JSONEncoding.default, dataType: StateResponseDTO.self)
            .map { dto in
                LoggerService.shared.debugLog("id: \(notificationId) - 알림 삭제 \(dto.state)")
                return dto.state
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.error(OtherError.notFoundSelf) }
                if let error = error as? NetworkError, error.statusCode == 401 {
                    guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
                        return Observable.error(TokenError.notFoundRefreshToken)
                    }
                    return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
                        .flatMap { newToken -> Observable<Bool> in
                            return APIService.shared.requestAPI(addEndPoint: "\(notificationId)", type: .deleteNoti, parameters: nil, headers: headers, encoding: JSONEncoding.default, dataType: StateResponseDTO.self)
                                .map { dto in
                                    LoggerService.shared.debugLog("id: \(notificationId) - 알림 삭제 \(dto.state)")
                                    return dto.state
                                }
                        }
                        .catch { error in
                            LoggerService.shared.debugLog("토큰 재발급 실패")
                            return Observable.error(error)
                        }
                }
                LoggerService.shared.log("\(error.localizedDescription)", level: .error)
                return Observable.error(error)
            }
    }
}
