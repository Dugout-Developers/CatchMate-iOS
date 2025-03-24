//
//  LoadChatUsersRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 2/4/25.
//
import UIKit
import RxSwift

final class LoadChatUsersRepositoryImpl: LoadChatUsersRepository {
    private let loadChatUserDS: LoadChatUsersDataSource
    
    init(loadChatUserDS: LoadChatUsersDataSource) {
        self.loadChatUserDS = loadChatUserDS
    }
    
    func loadChatRoomUsers(chatId: Int) -> RxSwift.Observable<[SenderInfo]> {
        return loadChatUserDS.loadChatRoomUser(chatId)
            .map { dto in
                var result = [SenderInfo]()
                for user in dto.userInfoList {
                    let sender = SenderInfo(senderId: user.userId, nickName: user.nickName, imageUrl: user.profileImageUrl)
                    result.append(sender)
                }
                return result
            }
    }
}
