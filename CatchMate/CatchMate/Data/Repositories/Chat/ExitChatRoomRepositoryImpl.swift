//
//  ExitChatRoomRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 2/14/25.
//

import UIKit
import RxSwift

final class ExitChatRoomRepositoryImpl: ExitChatRoomRepository {
    private let exitDS: ExitChatRoomDataSource
    init(exitDS: ExitChatRoomDataSource) {
        self.exitDS = exitDS
    }
    func exitRoom(chatId: Int) -> Observable<Void> {
        return exitDS.exitChatRoom(roomId: chatId)
            .flatMap { state in
                if state {
                    return Observable.just(())
                } else {
                    LoggerService.shared.log("exitRoom: State 값 False")
                    return Observable.error(MappingError.stateFalse)
                }
            }
    }
}
