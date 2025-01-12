//
//  TempPostDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 9/22/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol TempPostDataSource {
    func tempPost(_ post: PostRequsetDTO) -> Observable<Int>
}
final class TempPostDataSourceImpl: TempPostDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func tempPost(_ post: PostRequsetDTO) -> Observable<Int> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        let jsonDictionary = encodingData(post)
        LoggerService.shared.debugLog("parameters Encoding:\(jsonDictionary)")
        
        return APIService.shared.performRequest(type: .tempPost, parameters: jsonDictionary, headers: headers, encoding: JSONEncoding.default, dataType: AddPostResponseDTO.self, refreshToken: refreshToken)
            .map { response in
                LoggerService.shared.debugLog("임시저장 저장 성공 - result: \(response)")
                return response.boardId
            }
            .catch { error in
                LoggerService.shared.debugLog("임시저장 실패 - \(error)")
                return Observable.error(error)
            }
    }
    func encodingData(_ post: PostRequsetDTO) -> [String: Any] {
        var parameters: [String: Any] = [
            "title": post.title,
            "content": post.content,
            "maxPerson": post.maxPerson,
            "cheerClubId": post.cheerClubId,
            "preferredGender": post.preferredGender ?? "N",
            "preferredAgeRange": post.preferredAgeRange,
            "isCompleted": post.isCompleted
        ]
        if let gameDate = post.gameRequest.gameStartDate {
            parameters["gameRequest"] = [
                "homeClubId": post.gameRequest.homeClubId,
                "awayClubId": post.gameRequest.awayClubId,
                "gameStartDate": gameDate,
                "location": post.gameRequest.location
            ]
        } else {
            parameters["gameRequest"] = [
                "homeClubId": post.gameRequest.homeClubId,
                "awayClubId": post.gameRequest.awayClubId,
                "location": post.gameRequest.location
            ]
        }
        return parameters
    }
}
