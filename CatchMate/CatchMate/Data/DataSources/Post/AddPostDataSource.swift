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
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        LoggerService.shared.log("토큰 확인: \(headers)")
        
        
        let jsonDictionary = post.encodingData()
        LoggerService.shared.debugLog("parameters Encoding:\(jsonDictionary)")
        return APIService.shared.performRequest(type: .savePost, parameters: jsonDictionary, headers: headers, encoding: JSONEncoding.default, dataType: AddPostResponseDTO.self, refreshToken: refreshToken)
            .map({ response in
                LoggerService.shared.debugLog("Post 저장 성공 - result: \(response)")
                return response.boardId
            })
            .catch { error in
                LoggerService.shared.debugLog("Post 저장 실패 - \(error)")
                return Observable.error(error)
            }
    }
}

struct AddPostResponseDTO: Codable {
    let boardId: Int
}
