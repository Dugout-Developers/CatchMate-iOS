//
//  ExportChatUserRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 2/14/25.
//

import UIKit
import RxSwift

final class ExportChatUserRepositoryImpl: ExportChatUserRepository {
    private let exportDS: ExportChatUserDataSource
    init(exportDS: ExportChatUserDataSource) {
        self.exportDS = exportDS
    }
    func exportUser(chatId: Int, userId: Int) -> RxSwift.Observable<Void> {
        return exportDS.exportUser(roomId: chatId, userId: userId)
            .flatMap { state in
                if state {
                    return Observable.just(())
                } else {
                    LoggerService.shared.log("exportUser: State 값 False")
                    return Observable.error(MappingError.stateFalse)
                }
            }
    }
}
