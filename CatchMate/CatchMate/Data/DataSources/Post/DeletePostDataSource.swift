//
//  DeletePostDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 9/26/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol DeletePostDataSource {
    func deletePost(postId: Int) -> Observable<Void>
}

final class DeletePostDataSourceImpl: DeletePostDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func deletePost(postId: Int) -> RxSwift.Observable<Void> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        let parameters: [String: Any] = [
            "boardId": postId
        ]
        
        LoggerService.shared.debugLog("DeletePostDataSourceImpl 토큰 확인: \(headers)")
        
        return APIService.shared.requestVoidAPI(type: .removePost, parameters: parameters, headers: headers, encoding: JSONEncoding.default)
            .catch { [weak self] error in
                guard let self = self else { return Observable.error(ReferenceError.notFoundSelf) }
                if let error = error as? NetworkError, error.statusCode == 401 {
                    guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
                        return Observable.error(TokenError.notFoundRefreshToken)
                    }
                    return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
                        .flatMap { token in
                            let headers: HTTPHeaders = [
                                "AccessToken": token
                            ]
                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
                            return APIService.shared.requestVoidAPI(type: .removePost, parameters: parameters, headers: headers, encoding: JSONEncoding.default)
                        }
                        .catch { error in
                            return Observable.error(error)
                        }
                }
                return Observable.error(error)
            }
    }
}
