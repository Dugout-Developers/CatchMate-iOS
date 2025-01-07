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
        return loadNotificationRepository.loadNotificationList()
            .catch { error in
                return Observable.error(DomainError(error: error, context: .pageLoad, message: "알림 리스트 요청에 실패했습니다.").toPresentationError())
            }
    }
}
