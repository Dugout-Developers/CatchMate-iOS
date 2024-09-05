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
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    func setFavorite(_ state: Bool, _ boardID: String) -> RxSwift.Observable<Bool> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
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
            .catch { [weak self] error in
                guard let self = self else { return Observable.error(ReferenceError.notFoundSelf) }
                if let error = error as? NetworkError, error.statusCode == 401 {
                    guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
                        return Observable.error(TokenError.notFoundRefreshToken)
                    }
                    return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
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
