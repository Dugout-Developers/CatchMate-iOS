//
//  UserPostLoadDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 9/24/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol UserPostLoadDataSource {
    func loadUserPostList(_ userId: Int, page: Int) -> Observable<[PostListDTO]>
}

final class UserPostLoadDataSourceImpl: UserPostLoadDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadUserPostList(_ userId: Int, page: Int) -> RxSwift.Observable<[PostListDTO]> {
        LoggerService.shared.debugLog("\(userId) 게시글 - page \(page) 조회")
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        let parameters: [String: Any] = [
            "userId": userId,
            "page": page
        ]
        
        LoggerService.shared.debugLog("parameters: \(parameters)")
        LoggerService.shared.debugLog("PostListLoadDataSourceImpl 토큰 확인: \(headers)")
        return APIService.shared.requestAPI(type: .userPostlist, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: [PostListDTO].self)
            .map { postListDTO in
                LoggerService.shared.debugLog("PostList Load 성공: \(postListDTO)")
                return postListDTO
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.error(ReferenceError.notFoundSelf) }
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
                            return APIService.shared.requestAPI(type: .userPostlist, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: [PostListDTO].self)
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

