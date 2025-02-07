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
        
        return APIService.shared.performRequest(addEndPoint: "\(postId)", type: .removePost, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: DeletePostResponseDTO.self, refreshToken: refreshToken)
            .map({ dto in
                LoggerService.shared.log(level: .info, "게시물 삭제 - 요청Id: \(postId) / 처리Id: \(dto.boardId)")
                return ()
            })
            .catch { error in
                LoggerService.shared.log(level: .debug, "\(postId)번 게시물 삭제 실패 - \(error)")
                return Observable.error(error)
            }
    }
}

struct DeletePostResponseDTO: Codable {
    let boardId: Int
    let deletedAt: String
}
