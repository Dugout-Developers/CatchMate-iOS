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
    func editPost(_ post: EditPostRequsetDTO) -> Observable<Int>
}
final class EditPostDataSourceImpl: EditPostDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    func editPost(_ post: EditPostRequsetDTO) -> Observable<Int> {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        LoggerService.shared.log("토큰 확인: \(headers)")
        
        do {
            let jsonData = try encoder.encode(post)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            print(jsonObject)
            if let jsonDictionary = jsonObject as? [String: Any] {
                LoggerService.shared.debugLog("parameters Encoding:\(jsonDictionary)")
                return APIService.shared.requestAPI(type: .editPost, parameters: jsonDictionary, headers: headers, encoding: JSONEncoding.default, dataType: AddPostResponseDTO.self)
                    .map({ response in
                        LoggerService.shared.debugLog("Post 수정 성공 - result: \(response)")
                        return response.boardId
                    })
                    .catch { [weak self] error in
                        guard let self = self else { return Observable.error(ReferenceError.notFoundSelf) }
                        if let error = error as? NetworkError, error.statusCode == 401 {
                            guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
                                return Observable.error(TokenError.notFoundRefreshToken)
                            }
                            return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
                                .flatMap { newToken -> Observable<Int> in
                                    return APIService.shared.requestAPI(type: .editPost, parameters: jsonDictionary, headers: headers, encoding: JSONEncoding.default, dataType: AddPostResponseDTO.self)
                                        .map({ response in
                                            LoggerService.shared.debugLog("Post 수정 성공 - result: \(response)")
                                            return response.boardId
                                        })
                                }
                                .catch { error in
                                    return Observable.error(error)
                                }
                        }
                        LoggerService.shared.log("Post DATASOURCE 저장 실패: ", level: .error)
                        LoggerService.shared.log("JSON Data: \(String(data: jsonData, encoding: .utf8) ?? "") \n headers: \(headers)", level: .error)
                        LoggerService.shared.log("\(error.localizedDescription)", level: .error)
                        return Observable.error(error)
                    }
            } else {
                LoggerService.shared.log("EditPostDataSource: PostRequset 인코딩 실패", level: .error)
                return Observable.error(CodableError.encodingFailed)
            }
        } catch {
            LoggerService.shared.log("EditPostDataSource: PostRequset 인코딩 실패", level: .error)
            return Observable.error(CodableError.encodingFailed)
        }
    }
}

