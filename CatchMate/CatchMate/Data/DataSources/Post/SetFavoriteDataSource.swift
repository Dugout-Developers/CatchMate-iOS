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
    func setFavorite(_ state: Bool, _ boardID: String) -> Observable<[PostListDTO]>
}

final class SetFavoriteDataSourceImpl: SetFavoriteDataSource {
    func setFavorite(_ state: Bool, _ boardID: String) -> RxSwift.Observable<[PostListDTO]> {
        guard let token = KeychainService.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        let parameters: [String: Any] = ["flag": state ? 1 : 0]
        LoggerService.shared.log("토큰 확인: \(headers)")
        
        return APIService.shared.requestVoidAPI(addEndPoint: boardID, type: .setFavorite, parameters: parameters, headers: headers, encoding: URLEncoding.queryString)
            .map { _ in
                return []
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
                                .map { _ in
                                    LoggerService.shared.debugLog("FavoriteList Load 성공")
                                    return []
                                }
                                .catch { error in
                                    return Observable.error(error)
                                }
                        }
                }
                return Observable.error(error)
            }
//        return APIService.shared.requestAPI(addEndPoint: boardID, type: .setFavorite, parameters: parameters, headers: headers, encoding: URLEncoding.queryString, dataType: [PostListDTO].self)
//            .map { dto in
//                LoggerService.shared.debugLog("Favorite 업데이트 성공: \(dto)")
//                return dto
//            }
//            .catch { error in
//                if let networkError = error as? NetworkError, networkError.statusCode == 401 {
//                    return APIService.shared.refreshAccessToken()
//                        .flatMap { token -> Observable<[PostListDTO]> in
//                            let headers: HTTPHeaders = [
//                                "AccessToken": token
//                            ]
//                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
//                            return APIService.shared.requestAPI(type: .loadFavorite, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: [PostListDTO].self)
//                                .map { favoriteDTOList in
//                                    LoggerService.shared.debugLog("FavoriteList Load 성공: \(favoriteDTOList)")
//                                    return favoriteDTOList
//                                }
//                                .catch { error in
//                                    return Observable.error(error)
//                                }
//                        }
//                }
//                return Observable.error(error)
//            }
    }
}
