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
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        let addEndPoint = "\(chatId)/user-list"
        
        return APIService.shared.performRequest(addEndPoint: addEndPoint, type: .chatUsers, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: ChatRoomUsersDTO.self, refreshToken: refreshToken)
            .map { dto in
                print("userList 불러오기 성공 - \(dto)")
                return dto
            }
            .catch { error in
                LoggerService.shared.debugLog("유저정보 불러오기 실패 - \(error)")
                return Observable.error(error)
            }
    }
}
