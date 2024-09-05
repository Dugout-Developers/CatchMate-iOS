//
//  LoadFavoriteListDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 8/22/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol LoadFavoriteListDataSource {
    func loadFavoriteList() ->  Observable<[PostListDTO]>
}

final class LoadFavoriteListDataSourceImpl: LoadFavoriteListDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadFavoriteList() -> RxSwift.Observable<[PostListDTO]>{
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        LoggerService.shared.log("토큰 확인: \(headers)")
        
        return APIService.shared.requestAPI(type: .loadFavorite, parameters: nil, headers: headers, dataType: [PostListDTO].self)
            .map { favoriteListDTO in
                LoggerService.shared.debugLog("Favorite List Load 성공: \(favoriteListDTO)")
                return favoriteListDTO
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.error(ReferenceError.notFoundSelf) }
                if let error = error as? NetworkError, error.statusCode == 401 {
                    guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
                        return Observable.error(TokenError.notFoundRefreshToken)
                    }
                    return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
                        .flatMap { token -> Observable<[PostListDTO]> in
                            let newHeaders: HTTPHeaders = [
                                "AccessToken": token
                            ]
                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
                            return APIService.shared.requestAPI(type: .loadFavorite, parameters: nil, headers: newHeaders, encoding: URLEncoding.default, dataType: [PostListDTO].self)
                                .map { favoriteDTOList in
                                    LoggerService.shared.debugLog("FavoriteList Load 성공: \(favoriteDTOList)")
                                    return favoriteDTOList
                                }
                                .catch { error in
                                    return Observable.error(error)
                                }
                        }
                }
                return Observable.error(error)
            }
    }
    
}
