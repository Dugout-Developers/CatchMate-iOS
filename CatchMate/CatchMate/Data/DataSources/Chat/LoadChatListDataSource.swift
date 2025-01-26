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
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        let parameters: [String: Any] = [
            "page": page
        ]
        
        return APIService.shared.performRequest(type: .chatList, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: ChatListDTO.self, refreshToken: refreshToken)
            .map { dto in
                LoggerService.shared.debugLog("ChatList Load 성공: \(dto)")
                return dto
            }
            .catch { error in
                LoggerService.shared.debugLog("ChatList Load 실패 - \(error)")
                return Observable.error(error)
            }
    }
}

