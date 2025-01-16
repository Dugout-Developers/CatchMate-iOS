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
    func loadFavoriteList() ->  Observable<[PostListInfoDTO]>
}

final class LoadFavoriteListDataSourceImpl: LoadFavoriteListDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadFavoriteList() -> RxSwift.Observable<[PostListInfoDTO]>{
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        LoggerService.shared.log("토큰 확인: \(headers)")
        return APIService.shared.performRequest(type: .loadFavorite, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: PostListDTO.self, refreshToken: refreshToken)
            .map { favoriteListDTO in
                LoggerService.shared.debugLog("Favorite List Load 성공: \(favoriteListDTO)")
                return favoriteListDTO.boardInfoList
            }
            .catch { error in
                LoggerService.shared.debugLog("Favorite List Load 실패 - \(error)")
                Observable.error(error)
            }
    }
    
}
