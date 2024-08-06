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

/*
 요청 Post
 {
   "title": "string",
   "gameDate": "2024-08-06T11:38:53.235Z",
   "location": "string",
   "homeTeam": "string",
   "awayTeam": "string",
   "currentPerson": 0,
   "maxPerson": 0,
   "preferGender": "string",
   "preferAge": 0,
   "addInfo": "string",
   "writeDate": "2024-08-06T11:38:53.235Z"
 }
 리스폰
 200 {}
 */
protocol AddPostDataSource {
    func addPost(_ post: PostRequset) -> Observable<Void>
}
final class AddPostDataSourceImpl: AddPostDataSource {
    private var isRefreshingToken = false
    func addPost(_ post: PostRequset) -> Observable<Void> {
        let encoder = JSONEncoder()
        guard let token = KeychainService.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        do {
            let jsonData = try encoder.encode(post)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            if let jsonDictionary = jsonObject as? [String: Any] {
                return APIService.shared.requestAPI(type: .savePost, parameters: jsonDictionary, headers: headers, encoding: JSONEncoding.default, dataType: VoidResponse.self)
                    .map { _ in
                        LoggerService.shared.debugLog("Post 저장 성공: \(jsonData)")
                        return Void()
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
                        return Observable.error(error)
                    }
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
                   self.isRefreshingToken = false  // 토큰 갱신 성공 후 플래그 초기화
                   return Observable.just(Void())
               }
               .catch { error in
                   LoggerService.shared.log("토큰 갱신 실패: \(error.localizedDescription)", level: .error)

                   return Observable.error(NetworkError.tokenRefreshFailed)
               }
       }
}

struct VoidResponse: Codable {}
