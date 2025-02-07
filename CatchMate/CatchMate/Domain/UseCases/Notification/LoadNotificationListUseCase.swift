//
//  LoadNotificationListUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 1/7/25.
//
import RxSwift

protocol LoadNotificationListUseCase {
    func execute() -> Observable<[NotificationList]>
}

final class LoadNotificationListUseCaseImpl: LoadNotificationListUseCase {
    private let loadNotificationRepository: LoadNotificationListRepository
    init(loadNotificationRepository: LoadNotificationListRepository) {
        self.loadNotificationRepository = loadNotificationRepository
    }
    
    func execute() -> RxSwift.Observable<[NotificationList]> {
        LoggerService.shared.log(level: .info, "알림 리스트 불러오기")
        return loadNotificationRepository.loadNotificationList()
            .catch { error in
                let domainError = DomainError(error: error, context: .pageLoad, message: "알림 리스트를 불러오는데 문제가 발생했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "load_notification", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
