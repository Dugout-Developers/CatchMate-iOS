//
//  ExitChatRoomRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 2/14/25.
//

import UIKit
import RxSwift

protocol ExitChatRoomRepository {
    func exitRoom(chatId: Int) -> Observable<Void>
}
