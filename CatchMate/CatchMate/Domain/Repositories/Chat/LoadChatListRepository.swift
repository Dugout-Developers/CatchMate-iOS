//
//  LoadChatListRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 1/26/25.
//
import UIKit
import RxSwift

protocol LoadChatListRepository {
    func loadChatList(page: Int) -> Observable<(chatList: [ChatListInfo], isLast: Bool)>
}
