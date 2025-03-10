//
//  LoadNotificationListRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 1/7/25.
//

import UIKit
import RxSwift

final class LoadNotificationListRepositoryImpl: LoadNotificationListRepository {
    private let loadNotificationListDS: NotificationListDataSource
    private let loadNotificationDS: LoadNotificationDataSource
    
    init(loadNotificationDS: NotificationListDataSource, loadNotiDS: LoadNotificationDataSource) {
        self.loadNotificationListDS = loadNotificationDS
        self.loadNotificationDS = loadNotiDS
    }
    
    func loadNotificationList() -> RxSwift.Observable<[NotificationList]> {
        return loadNotificationListDS.loadNotificationList()
            .map { dtoList in
                var result = [NotificationList]()
                for dto in dtoList {
                    if let notification = NotificationMapper.dtoToDomain(dto) {
                        result.append(notification)
                    }  else {
                        LoggerService.shared.log("\(dto.notificationId) 매핑 실패")
                    }
                }
                return result
            }
    }
    
    func loadNotification(_ id: Int) -> RxSwift.Observable<NotificationList> {
        return loadNotificationDS.loadNotification(id)
            .flatMap { dto -> Observable<NotificationList> in
                guard let notification = NotificationMapper.dtoToDomain(dto) else {
                    return Observable.error(MappingError.invalidData)
                }
                return Observable.just(notification)
            }
    }
}
