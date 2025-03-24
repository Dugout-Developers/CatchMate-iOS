//
//  ExportChatUserUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 2/14/25.
//

import UIKit
import RxSwift

protocol ExportChatUserUseCase {
    func exportUser(chatId: Int, userId: Int) -> Observable<Void>
}

final class ExportChatUserUseCaseImpl: ExportChatUserUseCase {
    private let exportRepo: ExportChatUserRepository
    init(exportRepo: ExportChatUserRepository) {
        self.exportRepo = exportRepo
    }
    
    func exportUser(chatId: Int, userId: Int) -> Observable<Void> {
        return exportRepo.exportUser(chatId: chatId, userId: userId)
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "유저 내보내기에 실패했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "export_chatuser", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
