//
//  SetFavoriteDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 8/22/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol SetFavoriteDataSource {
    func setFavorite(_ state: Bool, _ boardID: String) -> Observable<Bool>
}

final class SetFavoriteDataSourceImpl: SetFavoriteDataSource {
    func setFavorite(_ state: Bool, _ boardID: String) -> RxSwift.Observable<Bool> {
        guard let token = KeychainService.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        let parameters: [String: Any] = ["flag": state ? 1 : 0]
        LoggerService.shared.log("토큰 확인: \(headers)")
        
        return APIService.shared.requestVoidAPI(addEndPoint: boardID, type: .setFavorite, parameters: parameters, headers: headers, encoding: URLEncoding.queryString)
            .map { _ in
                return true
            }
            .catch { error in
                if let networkError = error as? NetworkError, networkError.statusCode == 401 {
                    return APIService.shared.refreshAccessToken()
                        .flatMap { token -> Observable<Bool> in
                            let headers: HTTPHeaders = [
                                "AccessToken": token
                            ]
                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
                            return APIService.shared.requestVoidAPI(addEndPoint: boardID, type: .setFavorite, parameters: parameters, headers: headers, encoding: URLEncoding.queryString)
                                .map { _ in
                                    LoggerService.shared.debugLog("FavoriteList Load 성공")
                                    return true
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
