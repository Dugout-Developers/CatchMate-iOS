//
//  SetChatRoomNotificationDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 3/13/25.
//
import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol SetChatRoomNotificationDataSource {
    func setChatRoomNotification(chatId: Int, _ status: Bool) -> Observable<Bool>
}

final class SetChatRoomNotificationDataSourceImpl: SetChatRoomNotificationDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func setChatRoomNotification(chatId: Int, _ status: Bool) -> RxSwift.Observable<Bool> {
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
        
        let addEndPoint = "\(chatId)/notification"
        let parameters: [String: Any] = [
            "chatRoomId": chatId,
            "enable": status
        ]
        return APIService.shared.performRequest(addEndPoint: addEndPoint, type: .chatRoomNotification, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: StateResponseDTO.self, refreshToken: refreshToken)
            .map { dto in
                LoggerService.shared.log("\(chatId)번 채팅방 정보 조회 성공: \(dto)")
                return dto.state
            }
            .catch { error in
                LoggerService.shared.log("\(chatId)번 채팅방 정보 조회 실패: \(error)")
                return Observable.error(error)
            }
    }
    
    
}
