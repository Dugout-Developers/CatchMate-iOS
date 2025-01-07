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
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        let parameters: [String: Any] = [
            "alarmType": type,
            "isEnabled": isEnabled
        ]
        
        return APIService.shared.requestAPI(type: .setNotification, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: SetNotificationResponseDTO.self)
            .do(onNext: { dto in
                LoggerService.shared.debugLog("\(Endpoint.setNotification.apiName) Success - \(dto)")
            })
            .catch { [weak self] error in
                guard let self else { return Observable.error(OtherError.notFoundSelf) }
                if let error = error as? NetworkError, error.statusCode == 401 {
                    guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
                        return Observable.error(TokenError.notFoundRefreshToken)
                    }
                    
                    return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
                        .flatMap { token -> Observable<SetNotificationResponseDTO> in
                            let newHeaders: HTTPHeaders = [
                                "AccessToken": token
                            ]
                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
                            return APIService.shared.requestAPI(type: .setNotification, parameters: parameters, headers: newHeaders, encoding: JSONEncoding.default, dataType: SetNotificationResponseDTO.self)
                                .do(onNext: { dto in
                                    LoggerService.shared.debugLog("\(Endpoint.setNotification.apiName) Success - \(dto)")
                                })
                        }
                        .catch { error in
                            return Observable.error(error)
                        }
                }
                return Observable.error(error)
            }
    }
}
