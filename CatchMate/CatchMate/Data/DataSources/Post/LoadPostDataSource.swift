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
    func laodPost(postId: Int) ->  Observable<PostDTO>
}

final class LoadPostDataSourceImpl: LoadPostDataSource {
    func laodPost(postId: Int) -> RxSwift.Observable<PostDTO> {
        guard let token = KeychainService.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        return APIService.shared.requestAPI(addEndPoint: String(postId),type: .loadPost, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: PostDTO.self)
            .map { dto in
                LoggerService.shared.debugLog("Post Load 성공: \(dto)")
                return dto
            }
            .catch { error in
                if let networkError = error as? NetworkError, networkError.statusCode == 401 {
                    return APIService.shared.refreshAccessToken()
                        .flatMap { token -> Observable<PostDTO> in
                            let newHeaders: HTTPHeaders = [
                                "AccessToken": token
                            ]
                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
                            return APIService.shared.requestAPI(addEndPoint: String(postId),type: .loadPost, parameters: nil, headers: newHeaders, encoding: URLEncoding.default, dataType: PostDTO.self)
                                .map { dto in
                                    LoggerService.shared.debugLog("Post Load 성공: \(dto)")
                                    return dto
                                }
                                .catch { error in
                                    return Observable.error(error)
                                }
                        }
                }
                return Observable.error(error)
            }
    }
}
