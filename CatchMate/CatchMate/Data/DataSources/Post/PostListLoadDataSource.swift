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
    func loadPostList(pageNum: Int, gudan: String, gameDate: String) ->  Observable<[PostListDTO]>
}
final class PostListLoadDataSourceImpl: PostListLoadDataSource {
    func loadPostList(pageNum: Int, gudan: String, gameDate: String) -> RxSwift.Observable<[PostListDTO]> {
        LoggerService.shared.debugLog("<필터값> 구단: \(gudan), 날짜: \(gameDate)")
        guard let token = KeychainService.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        // MARK: - 임시 필터
        var gudan = gudan
        var gameDate = gameDate
        if gudan.isEmpty && gameDate.isEmpty {
            gudan = "다이노스"
            gameDate = "2024-08-16"
        }
        
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        let parameters: [String: Any] = [
            "gudan": gudan,
            "gameDate": gameDate
        ]
        LoggerService.shared.debugLog("PostListLoadDataSourceImpl 토큰 확인: \(headers)")
        return APIService.shared.requestAPI(addEndPoint: String(pageNum), type: .postlist, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: [PostListDTO].self)
            .map { postListDTO in
                LoggerService.shared.debugLog("PostList Load 성공: \(postListDTO)")
                return postListDTO
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



