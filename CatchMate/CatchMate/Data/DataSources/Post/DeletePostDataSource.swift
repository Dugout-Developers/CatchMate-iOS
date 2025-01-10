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
        LoggerService.shared.debugLog("DeletePostDataSourceImpl 토큰 확인: \(headers)")
        
        return APIService.shared.requestAPI(addEndPoint: "\(postId)", type: .removePost, parameters: nil, headers: headers, encoding: JSONEncoding.default, dataType: DeletePostResponseDTO.self)
            .map({ dto in
                LoggerService.shared.debugLog("게시물 삭제 - 요청Id: \(postId) / 처리Id: \(dto.boardId)")
                return ()
            })
            .catch { [weak self] error in
                guard let self = self else { return Observable.error(OtherError.notFoundSelf) }
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
                            return APIService.shared.requestAPI(addEndPoint: "\(postId)", type: .removePost, parameters: nil, headers: headers, encoding: JSONEncoding.default, dataType: DeletePostResponseDTO.self)
                                .map { dto in
                                    LoggerService.shared.debugLog("게시물 삭제 - 요청Id: \(postId) / 처리Id: \(dto.boardId)")
                                    return ()
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

struct DeletePostResponseDTO: Codable {
    let boardId: Int
    let deletedAt: String
}
