//
//  LoadChatUsersRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 2/4/25.
//

import UIKit
import RxSwift

protocol LoadChatUsersRepository {
    func loadChatRoomUsers(chatId: Int) -> Observable<[SenderInfo]>
}
