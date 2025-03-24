//
//  AddPostDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol AddPostDataSource {
    func addPost(_ post: PostRequsetDTO) -> Observable<Int>
}
final class AddPostDataSourceImpl: AddPostDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    func addPost(_ post: PostRequsetDTO) -> Observable<Int> {

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
        
        guard let jsonDictionary = post.encodingData() else {
            LoggerService.shared.log(level: .debug, "게시물 파라미터 변환 실패")
            return Observable.error(MappingError.mappingFailed)
        }
        LoggerService.shared.log(level: .info, "parameters Encoding:\(jsonDictionary)")
        
        return APIService.shared.performRequest(type: .savePost, parameters: jsonDictionary, headers: headers, encoding: JSONEncoding.default, dataType: AddPostResponseDTO.self, refreshToken: refreshToken)
            .map({ response in
                return response.boardId
            })
            .catch { error in
                LoggerService.shared.log(level: .debug, "Post 저장 실패 - \(error)")
                return Observable.error(error)
            }
    }
}

struct AddPostResponseDTO: Codable {
    let boardId: Int
}
