//
//  LoadChatUsersDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 2/4/25.
//
import UIKit
import RxSwift
import RxAlamofire
import Alamofire

struct ChatRoomUsersDTO: Codable {
    let userInfoList: [UserDTO]
}
protocol LoadChatUsersDataSource {
    func loadChatRoomUser(_ chatId: Int) -> Observable<ChatRoomUsersDTO>
}

final class LoadChatUsersDataSourceImpl: LoadChatUsersDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadChatRoomUser(_ chatId: Int) -> RxSwift.Observable<ChatRoomUsersDTO> {
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
        let addEndPoint = "\(chatId)/user-list"
        
        return APIService.shared.performRequest(addEndPoint: addEndPoint, type: .chatUsers, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: ChatRoomUsersDTO.self, refreshToken: refreshToken)
            .catch { error in
                LoggerService.shared.log("유저정보 불러오기 실패 - \(error)")
                return Observable.error(error)
            }
    }
}
