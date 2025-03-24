//
//  LoadPostDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 8/15/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol LoadPostDataSource {
    func loadPost(postId: Int) ->  Observable<PostDTO>
}

final class LoadPostDataSourceImpl: LoadPostDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    func loadPost(postId: Int) -> RxSwift.Observable<PostDTO> {
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
        return APIService.shared.performRequest(addEndPoint: String(postId), type: .loadPost, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: PostDTO.self, refreshToken: refreshToken)
            .catch { error in
                LoggerService.shared.log(level: .debug, "Post 로드 실패: \(error.localizedDescription)")
                return Observable.error(error)
            }
       
    }
}
