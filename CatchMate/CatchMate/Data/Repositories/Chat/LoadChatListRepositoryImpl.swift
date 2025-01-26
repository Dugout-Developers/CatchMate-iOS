//
//  LoadChatListRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 1/26/25.
//
import UIKit
import RxSwift

final class LoadChatListRepositoryImpl: LoadChatListRepository {
    private let chatListDataSource: LoadChatListDataSource
    
    init(chatListDataSource: LoadChatListDataSource) {
        self.chatListDataSource = chatListDataSource
    }
    
    func loadChatList(page: Int) -> RxSwift.Observable<(chatList: [ChatListInfo], isLast: Bool)> {
        return chatListDataSource.loadChatList(page: page)
            .map { dto in
                let isLast = dto.isLast
                var list = [ChatListInfo]()
                
                dto.chatRoomInfoList.forEach { listDto in
                    let mapper = ChatMapper()
                    if let chatInfo = mapper.dtoToDomain(listDto) {
                        list.append(chatInfo)
                    }
                }
                
                return (list, isLast)
            }
    }
}
