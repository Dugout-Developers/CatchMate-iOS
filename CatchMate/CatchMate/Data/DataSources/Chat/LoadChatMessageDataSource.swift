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
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
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
            .map { dto in
                print("이전 메시지 불러오기 성공 - \(dto)")
                return dto
            }
            .catch { error in
                LoggerService.shared.debugLog("이전 메시지 불러오기 실패 - \(error)")
                return Observable.error(error)
            }
    }
    
}
