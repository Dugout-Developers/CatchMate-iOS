//
//  FavoritePostLoadDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 8/13/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol PostListLoadDataSource {
    func loadPostList(pageNum: Int, gudan: [Int], gameDate: String, people: Int) ->  Observable<PostListDTO>
}
final class PostListLoadDataSourceImpl: PostListLoadDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadPostList(pageNum: Int, gudan: [Int], gameDate: String, people: Int) -> RxSwift.Observable<PostListDTO> {
        LoggerService.shared.debugLog("<필터값> 구단: \(gudan), 날짜: \(gameDate), 페이지: \(pageNum)")
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        var parameters: [String: Any] = [:]
        parameters["page"] = pageNum
        if !gameDate.isEmpty {
            parameters["gameStartDate"] = gameDate
        }

        if !gudan.isEmpty {
            parameters["preferredTeamIdList"] = gudan
        }
        
        if people > 0 && people < 9 {
            parameters["maxPerson"] = people
        }
        
        
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
    
        
        LoggerService.shared.debugLog("parameters: \(parameters)")
        LoggerService.shared.debugLog("PostListLoadDataSourceImpl 토큰 확인: \(headers)")
        return APIService.shared.performRequest(type: .postlist, parameters: parameters, headers: headers, encoding: CustomURLEncoding.default, dataType: PostListDTO.self, refreshToken: refreshToken)
            .map { dto in
                LoggerService.shared.debugLog("PostList Load 성공: \(dto)")
                return dto
            }
            .catch { error in
                LoggerService.shared.debugLog("PostList Load 실패 - \(error)")
                return Observable.error(error)
            }
    }
}



