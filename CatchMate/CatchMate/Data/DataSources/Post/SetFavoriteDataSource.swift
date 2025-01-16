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
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        LoggerService.shared.log("토큰 확인: \(headers)")
        
        return APIService.shared.performRequest(addEndPoint: boardID, type: .setFavorite, parameters: nil, headers: headers, encoding: URLEncoding.queryString, dataType: FavoriteResponse.self, refreshToken: refreshToken)
            .map { _ in
                LoggerService.shared.debugLog("찜하기 성공")
                return true
            }
            .catch { error in
                LoggerService.shared.debugLog("찜하기 실패 - \(error)")
                return Observable.error(error)
            }
    }
    
    func deleteFavorite(_ boardID: String) -> RxSwift.Observable<Bool> {
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
        
        return APIService.shared.performRequest(addEndPoint: boardID, type: .deleteFavorite, parameters: nil, headers: headers, encoding: URLEncoding.queryString, dataType: FavoriteResponse.self, refreshToken: refreshToken)
            .map { _ in
                LoggerService.shared.debugLog("찜삭제 성공")
                return true
            }
            .catch { error in
                LoggerService.shared.debugLog("찜삭제 실패 - \(error)")
                return Observable.error(error)
            }
            
    }
}

struct FavoriteResponse: Codable {
    let state: Bool
}
