//
//  DeleteNotificationUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 1/8/25.
//

import RxSwift

protocol DeleteNotificationUseCase {
    func deleteNotification(_ notificationId: String) -> Observable<Bool>
}

final class DeleteNotificationUseCaseImpl: DeleteNotificationUseCase {
    private let deleteNotiRepository: DeleteNotificationRepository
    init(deleteNotiRepository: DeleteNotificationRepository) {
        self.deleteNotiRepository = deleteNotiRepository
    }
    
    func deleteNotification(_ notificationId: String) -> Observable<Bool> {
        guard let id = Int(notificationId) else {
            LoggerService.shared.debugLog("deleteNotification - id값을 변환하는데 실패했습니다.")
            return Observable.error(PresentationError.showToastMessage(message: "알림을 삭제하는데 문제가 발생했습니다."))
        }
        return deleteNotiRepository.deleteNotification(notificationId: id)
            .catch { error in
                return Observable.error(DomainError(error: error, context: .action, message: "알림을 삭제하는데 문제가 발생했습니다.").toPresentationError())
            }
    }
}
