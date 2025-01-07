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
    func setFavorite(_ boardID: String) -> Observable<Bool>
    func deleteFavorite(_ boardID: String) -> Observable<Bool>
}

final class SetFavoriteDataSourceImpl: SetFavoriteDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    func setFavorite(_ boardID: String) -> RxSwift.Observable<Bool> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        LoggerService.shared.log("토큰 확인: \(headers)")
        
        return APIService.shared.requestAPI(addEndPoint: boardID, type: .setFavorite, parameters: nil, headers: headers, encoding: URLEncoding.queryString, dataType: FavoriteResponse.self)
            .map { _ in
                return true
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.error(OtherError.notFoundSelf) }
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
                            return APIService.shared.requestAPI(addEndPoint: boardID, type: .setFavorite, parameters: nil, headers: headers, encoding: URLEncoding.queryString, dataType: FavoriteResponse.self)
                                .map { _ in
                                    LoggerService.shared.debugLog("찜하기 성공")
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
    
    func deleteFavorite(_ boardID: String) -> RxSwift.Observable<Bool> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        LoggerService.shared.log("토큰 확인: \(headers)")
        
        return APIService.shared.requestAPI(addEndPoint: boardID, type: .deleteFavorite, parameters: nil, headers: headers, encoding: URLEncoding.queryString, dataType: FavoriteResponse.self)
            .map { _ in
                return true
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.error(OtherError.notFoundSelf) }
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
                            return APIService.shared.requestAPI(addEndPoint: boardID, type: .setFavorite, parameters: nil, headers: headers, encoding: URLEncoding.queryString, dataType: FavoriteResponse.self)
                                .map { _ in
                                    LoggerService.shared.debugLog("찜삭제 성공")
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

struct FavoriteResponse: Codable {
    let state: Bool
}
