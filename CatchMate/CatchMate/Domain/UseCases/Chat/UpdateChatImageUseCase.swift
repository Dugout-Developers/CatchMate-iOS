//
//  UpdateChatImageUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 2/13/25.
//

import UIKit
import RxSwift

protocol UpdateChatImageUseCase {
    func execute(chatId: Int, _ image: UIImage) -> Observable<Bool>
}

final class UpdateChatImageUseCaseImpl: UpdateChatImageUseCase {
    private let updateImageRepo: UpdateChatImageRepository
    init(updateImageRepo: UpdateChatImageRepository) {
        self.updateImageRepo = updateImageRepo
    }
    func execute(chatId: Int, _ image: UIImage) -> RxSwift.Observable<Bool> {
        return updateImageRepo.updateImage(chatId: chatId, image)
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "이미지 수정에 실패했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "update_chatimage", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
