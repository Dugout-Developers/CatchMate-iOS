//
//  SetNotificationDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 12/20/24.
//
import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol SetAlarmDataSource {
    func setNotification(type: String, isEnabled: String) -> Observable<SetNotificationResponseDTO>
}

final class SetAlarmDataSourceImpl: SetAlarmDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func setNotification(type: String, isEnabled: String) -> Observable<SetNotificationResponseDTO> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        let parameters: [String: Any] = [
            "alarmType": type,
            "isEnabled": isEnabled
        ]
        return APIService.shared.performRequest(type: .setNotification, parameters: parameters, headers: headers, encoding: JSONEncoding.default, dataType: SetNotificationResponseDTO.self, refreshToken: refreshToken)
            .do(onNext: { dto in
                LoggerService.shared.debugLog("\(Endpoint.setNotification.apiName) Success - \(dto)")
            })
            .catch { error in
                return Observable.error(error)
            }
    }
}
