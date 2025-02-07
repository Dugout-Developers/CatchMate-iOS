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
    func loadUserPostList(_ userId: Int, page: Int) -> Observable<PostListDTO>
}

final class UserPostLoadDataSourceImpl: UserPostLoadDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadUserPostList(_ userId: Int, page: Int) -> RxSwift.Observable<PostListDTO> {
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
        
        let paramters: [String: Any] = [
            "page": page
        ]
        
        return APIService.shared.performRequest(addEndPoint: "\(userId)", type: .userPostlist, parameters: paramters, headers: headers, encoding: URLEncoding.default, dataType: PostListDTO.self, refreshToken: refreshToken)
            .catch { error in
                LoggerService.shared.log(level: .debug, "PostList Load 실패: \(error)")
                return Observable.error(error)
            }
    }
}

