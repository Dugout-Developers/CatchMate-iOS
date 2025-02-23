//
//  LoadChatDetailDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 2/23/25.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol LoadChatDetailDataSource {
    func loadChatDetail(_ chatId: Int) -> Observable<ChatRoomInfoDTO>
}

final class LoadChatDetailDataSourceImpl: LoadChatDetailDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadChatDetail(_ chatId: Int) -> RxSwift.Observable<ChatRoomInfoDTO> {
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
        
        return APIService.shared.performRequest(addEndPoint: addEndPoint, type: .chatDetail, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: ChatRoomInfoDTO.self, refreshToken: refreshToken)
            .do { dto in
                LoggerService.shared.log("\(chatId)번 채팅방 정보 조회 성공: \(dto)")
            }
            .catch { error in
                LoggerService.shared.log("\(chatId)번 채팅방 정보 조회 실패: \(error)")
                return Observable.error(error)
            }
    }
    
    
}
