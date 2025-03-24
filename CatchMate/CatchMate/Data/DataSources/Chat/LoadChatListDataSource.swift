//
//  LoadChatListDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 1/26/25.
//
import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol LoadChatListDataSource {
    func loadChatList(page: Int) -> Observable<ChatListDTO>
}

final class LoadChatListDataSourceImpl: LoadChatListDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadChatList(page: Int) -> RxSwift.Observable<ChatListDTO> {
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
        
        let parameters: [String: Any] = [
            "page": page
        ]
        
        return APIService.shared.performRequest(type: .chatList, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: ChatListDTO.self, refreshToken: refreshToken)
            .catch { error in
                LoggerService.shared.log("ChatList Load 실패 - \(error)")
                return Observable.error(error)
            }
    }
}

