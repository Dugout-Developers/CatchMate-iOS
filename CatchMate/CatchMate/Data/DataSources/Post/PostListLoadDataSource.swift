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
    func loadPostList(pageNum: Int, gudan: [Int], gameDate: String, people: Int, isGuest: Bool) ->  Observable<PostListDTO>
}
final class PostListLoadDataSourceImpl: PostListLoadDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadPostList(pageNum: Int, gudan: [Int], gameDate: String, people: Int, isGuest: Bool = false) -> RxSwift.Observable<PostListDTO> {
        LoggerService.shared.log(level: .debug, "<필터값> 구단: \(gudan), 날짜: \(gameDate), 페이지: \(pageNum)")

        let refreshToken = self.tokenDataSource.getToken(for: .refreshToken)
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
        
        
        var headers: HTTPHeaders = []
        if !isGuest {
            guard let token = tokenDataSource.getToken(for: .accessToken) else {
                LoggerService.shared.log(level: .debug, "엑세스 토큰 찾기 실패")
                return Observable.error(TokenError.notFoundAccessToken)
            }
            headers["AccessToken"] = token
        }
        return APIService.shared.performRequest(type: .postlist, parameters: parameters, headers: isGuest ? nil : headers, encoding: CustomURLEncoding.default, dataType: PostListDTO.self, refreshToken: refreshToken)
            .catch { error in
                LoggerService.shared.log(level: .debug, "PostList Load 실패 - \(error)")
                return Observable.error(error)
            }
    }
}



