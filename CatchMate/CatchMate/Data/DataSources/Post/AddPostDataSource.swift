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
    func addPost(_ post: AddPostRequsetDTO) -> Observable<Int>
}
final class AddPostDataSourceImpl: AddPostDataSource {
    private var isRefreshingToken = false
    func addPost(_ post: AddPostRequsetDTO) -> Observable<Int> {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let token = KeychainService.getToken(for: .accessToken) else {
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
                return APIService.shared.requestAPI(type: .savePost, parameters: jsonDictionary, headers: headers, encoding: JSONEncoding.default, dataType: AddPostResponseDTO.self)
                    .map { response in
                        LoggerService.shared.debugLog("Post 저장 성공 - result: \(response)")
                        return response.boardId
                    }
                    .catch { [weak self] error in
                        guard let self = self else { return Observable.error(error) }
                        if !self.isRefreshingToken, let networkError = error as? NetworkError, networkError.statusCode == 401 {
                            self.isRefreshingToken = true
                            return self.handleUnauthorizedError()
                                .flatMap { _ in
                                    return self.addPost(post)
                                }
                        }
                        LoggerService.shared.log("Post DATASOURCE 저장 실패: ", level: .error)
                        LoggerService.shared.log("JSON Data: \(String(data: jsonData, encoding: .utf8) ?? "") \n headers: \(headers)", level: .error)
                        LoggerService.shared.log("\(error.localizedDescription)", level: .error)
                        return Observable.error(error)
                    }
            } else {
                LoggerService.shared.log("AddPostDataSource: PostRequset 인코딩 실패", level: .error)
                return Observable.error(CodableError.encodingFailed)
            }
        } catch {
            LoggerService.shared.log("AddPostDataSource: PostRequset 인코딩 실패", level: .error)
            return Observable.error(CodableError.encodingFailed)
        }
    }
    
    private func handleUnauthorizedError() -> Observable<Void> {
           return APIService.shared.refreshAccessToken()
               .flatMap { newToken in
                   KeychainService.saveToken(token: newToken, for: .accessToken)
                   return Observable.just(Void())
               }
               .catch { error in
                   LoggerService.shared.log("토큰 갱신 실패: \(error.localizedDescription)", level: .error)

                   return Observable.error(NetworkError.tokenRefreshFailed)
               }
       }
}

struct AddPostResponseDTO: Codable {
    let boardId: Int
}
