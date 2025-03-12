//
//  LoadChatDetailRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 2/23/25.
//

import RxSwift

protocol LoadChatDetailRepository {
    func loadChat(_ chatId: Int) -> Observable<ChatListInfo>
    func loadChatNotificationStatus(_ chatId: Int) -> Observable<Bool>
}
