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
    func loadFavoriteList(page: Int) ->  Observable<PostListDTO>
}

final class LoadFavoriteListDataSourceImpl: LoadFavoriteListDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadFavoriteList(page: Int) -> RxSwift.Observable<PostListDTO>{
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        var parameters: [String: Any] = [:]
        parameters["page"] = page
        LoggerService.shared.log("토큰 확인: \(headers)")
        return APIService.shared.performRequest(type: .loadFavorite, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: PostListDTO.self, refreshToken: refreshToken)
            .map { favoriteListDTO in
                LoggerService.shared.debugLog("Favorite List Load 성공: \(favoriteListDTO)")
                return favoriteListDTO
            }
            .catch { error in
                LoggerService.shared.debugLog("Favorite List Load 실패 - \(error)")
                return Observable.error(error)
            }
    }
    
}
