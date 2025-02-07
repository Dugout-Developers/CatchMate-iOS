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
            LoggerService.shared.log(level: .debug, "엑세스 토큰 찾기 실패")
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refreshToken = self.tokenDataSource.getToken(for: .refreshToken) else {
            LoggerService.shared.log(level: .debug, "리프레시 토큰 찾기 실패")
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        var parameters: [String: Any] = [:]
        parameters["page"] = page

        return APIService.shared.performRequest(type: .loadFavorite, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: PostListDTO.self, refreshToken: refreshToken)
            .catch { error in
                LoggerService.shared.log(level: .debug, "Favorite List Load 실패 - \(error)")
                return Observable.error(error)
            }
    }
    
}
