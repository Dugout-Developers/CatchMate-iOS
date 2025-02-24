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
        let parameters: [String: Any] = [
            "alarmType": type,
            "isEnabled": isEnabled
        ]
        print(parameters)
        return APIService.shared.performRequest(type: .setNotification, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: SetNotificationResponseDTO.self, refreshToken: refreshToken)
            .catch { error in
                return Observable.error(error)
            }
    }
}
