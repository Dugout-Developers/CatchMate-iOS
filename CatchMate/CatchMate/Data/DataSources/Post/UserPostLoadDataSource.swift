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
    func loadUserPostList(_ userId: Int, page: Int) -> Observable<[PostListInfoDTO]>
}

final class UserPostLoadDataSourceImpl: UserPostLoadDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadUserPostList(_ userId: Int, page: Int) -> RxSwift.Observable<[PostListInfoDTO]> {
        LoggerService.shared.debugLog("\(userId) 게시글 - page \(page) 조회")
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        LoggerService.shared.debugLog("PostListLoadDataSourceImpl 토큰 확인: \(headers)")
        
        return APIService.shared.performRequest(addEndPoint: "\(userId)", type: .userPostlist, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: PostListDTO.self, refreshToken: refreshToken)
            .map { postListDTO in
                LoggerService.shared.debugLog("PostList Load 성공: \(postListDTO)")
                return postListDTO.boardInfoList
            }
            .catch { error in
                LoggerService.shared.debugLog("PostList Load 실패: \(error)")
                return Observable.error(error)
            }
    }
}

