//
//  FavoritePostLoadDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 8/13/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol PostListLoadDataSource {
    func loadPostList(isFavorite: Bool, pageNum: Int, gudan: String, gameDate: String) ->  Observable<[PostListDTO]>
}
final class PostListLoadDataSourceImpl: PostListLoadDataSource {
    func loadPostList(isFavorite: Bool, pageNum: Int, gudan: String, gameDate: String) -> RxSwift.Observable<[PostListDTO]> {
        guard let token = KeychainService.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]

        LoggerService.shared.debugLog("FavoritePostLoadDataSourceImpl 토큰 확인: \(headers)")
        return APIService.shared.requestAPI(type: isFavorite ? .loadFavorite : .loadPost, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: [PostListDTO].self)
            .map { favoriteDTOList in
                LoggerService.shared.debugLog("FavoriteList Load 성공: \(favoriteDTOList)")
                return favoriteDTOList
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.error(error) }
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



