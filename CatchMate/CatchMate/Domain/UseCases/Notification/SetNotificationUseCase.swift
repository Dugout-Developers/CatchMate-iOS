//
//  SetNotificationUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 12/20/24.
//

import UIKit
import RxSwift

protocol SetNotificationUseCase {
    func execute(type: NotificationType, state: Bool) -> Observable<Bool>
}

final class SetNotificationUseCaseImpl: SetNotificationUseCase {
    private let setNotificationRepository: SetNotificationRepository
    
    init(setNotificationRepository: SetNotificationRepository) {
        self.setNotificationRepository = setNotificationRepository
    }
    
    func execute(type: NotificationType, state: Bool) -> Observable<Bool> {
        return setNotificationRepository.setNotificationRepository(type: type, state: state)
            .catch { error in
                return Observable.error(DomainError(error: error, context: .action, message: "요청에 실패했습니다.").toPresentationError())
            }
    }
}
