//
//  LoadChatMessageDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 2/4/25.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol LoadChatMessageDataSource {
    func loadMessage(_ chatId: Int, page: Int) -> Observable<ChatMessageDTO>
}

final class LoadChatMessageDataSourceImpl: LoadChatMessageDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadMessage(_ chatId: Int, page: Int) -> Observable<ChatMessageDTO> {
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
        let addEndPoint = "\(chatId)"
        
        let parameters: [String: Any] = [
            "page": page,
            "size": 20
        ]
        
        return APIService.shared.performRequest(addEndPoint: addEndPoint, type: .chatMessage, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: ChatMessageDTO.self, refreshToken: refreshToken)
            .catch { error in
                LoggerService.shared.log("이전 메시지 불러오기 실패 - \(error)")
                return Observable.error(error)
            }
    }
    
}
