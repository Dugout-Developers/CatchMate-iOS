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
        
        
        return APIService.shared.performRequest(addEndPoint: boardID, type: .setFavorite, parameters: nil, headers: headers, encoding: URLEncoding.queryString, dataType: FavoriteResponse.self, refreshToken: refreshToken)
            .map { result in
                return result.state
            }
            .catch { error in
                LoggerService.shared.log(level: .debug, "찜하기 실패 - \(error)")
                return Observable.error(error)
            }
    }
    
    func deleteFavorite(_ boardID: String) -> RxSwift.Observable<Bool> {
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

        return APIService.shared.performRequest(addEndPoint: boardID, type: .deleteFavorite, parameters: nil, headers: headers, encoding: URLEncoding.queryString, dataType: FavoriteResponse.self, refreshToken: refreshToken)
            .map { result in
                return result.state
            }
            .catch { error in
                LoggerService.shared.log(level: .debug, "찜삭제 실패 - \(error)")
                return Observable.error(error)
            }
            
    }
}

struct FavoriteResponse: Codable {
    let state: Bool
}
