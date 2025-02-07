//
//  EditPostDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 10/3/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol EditPostDataSource {
    func editPost(_ post: PostRequsetDTO, boardId: Int) -> Observable<Int>
}
final class EditPostDataSourceImpl: EditPostDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    func editPost(_ post: PostRequsetDTO, boardId: Int) -> Observable<Int> {
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

        guard let parameters = post.encodingData() else {
            return Observable.error(MappingError.mappingFailed)
        }
        
        return APIService.shared.performRequest(addEndPoint: "\(boardId)", type: .editPost, parameters: parameters, headers: headers, encoding: JSONEncoding.default, dataType: AddPostResponseDTO.self, refreshToken: refreshToken)
            .map({ response in
                return response.boardId
            })
            .catch { error in
                LoggerService.shared.log(level: .debug, "Post 수정 실패 - \(error)")
                return Observable.error(error)
            }
    }
}

