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
    func loadPostList(pageNum: Int, gudan: [String], gameDate: String, people: Int) ->  Observable<[PostListDTO]>
}
final class PostListLoadDataSourceImpl: PostListLoadDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadPostList(pageNum: Int, gudan: [String], gameDate: String, people: Int) -> RxSwift.Observable<[PostListDTO]> {
        LoggerService.shared.debugLog("<필터값> 구단: \(gudan), 날짜: \(gameDate), 페이지: \(pageNum)")
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        
        var gameDate = gameDate
        if gameDate.isEmpty {
            gameDate = "9999-99-99"
        }
        
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        let parameters: [String: Any] = [
            "gudans": gudan.isEmpty ? "" : gudan,
            "gameDate": gameDate,
            "people": people
        ]
        
        LoggerService.shared.debugLog("parameters: \(parameters)")
        LoggerService.shared.debugLog("PostListLoadDataSourceImpl 토큰 확인: \(headers)")
        return APIService.shared.requestAPI(addEndPoint: String(pageNum), type: .postlist, parameters: parameters, headers: headers, encoding: CustomURLEncoding.default, dataType: [PostListDTO].self)
            .map { postListDTO in
                LoggerService.shared.debugLog("PostList Load 성공: \(postListDTO)")
                return postListDTO
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.error(OtherError.notFoundSelf) }
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
                            return APIService.shared.requestAPI(addEndPoint: String(pageNum), type: .postlist, parameters: parameters, headers: newHeaders, encoding: URLEncoding.default, dataType: [PostListDTO].self)
                                .map { postListDTO in
                                    LoggerService.shared.debugLog("PostList Load 성공: \(postListDTO)")
                                    return postListDTO
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



