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
    func loadFavoriteList() -> RxSwift.Observable<[PostListDTO]>{
        guard let token = KeychainService.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        LoggerService.shared.log("토큰 확인: \(headers)")
        
        return APIService.shared.requestAPI(type: .loadFavorite, parameters: nil, dataType: [PostListDTO].self)
            .map { favoriteListDTO in
                LoggerService.shared.debugLog("Favorite List Load 성공: \(favoriteListDTO)")
                return favoriteListDTO
            }
            .catch { error in
                if let networkError = error as? NetworkError, networkError.statusCode == 401 {
                    return APIService.shared.refreshAccessToken()
                        .flatMap { token -> Observable<[PostListDTO]> in
                            let headers: HTTPHeaders = [
                                "AccessToken": token
                            ]
                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
                            return APIService.shared.requestAPI(type: .loadFavorite, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: [PostListDTO].self)
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
