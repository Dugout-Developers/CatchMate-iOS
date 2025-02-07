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
        LoggerService.shared.log(level: .info, "알림 삭제")
        guard let id = Int(notificationId) else {
            let domainError = DomainError(error: OtherError.failureTypeCase, context: .action, message: "알림을 삭제하는데 문제가 발생했습니다.")
            LoggerService.shared.errorLog(domainError, domain: "delete_notification", message: OtherError.failureTypeCase.errorDescription ?? "id값 Int타입캐스팅 실패")
            return Observable.error(domainError)
        }
        return deleteNotiRepository.deleteNotification(notificationId: id)
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "알림을 삭제하는데 문제가 발생했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "delete_notification", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
