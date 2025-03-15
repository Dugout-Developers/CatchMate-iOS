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
    
    func loadNotificationList(_ page: Int) -> RxSwift.Observable<(list: [NotificationList], isLast: Bool)> {
        return loadNotificationListDS.loadNotificationList(page)
            .map { dto in
                var result = [NotificationList]()
                for notification in dto.notificationInfoList {
                    if let mappingResult = NotificationMapper.dtoToDomain(notification) {
                        result.append(mappingResult)
                    }  else {
                        LoggerService.shared.log("\(notification.notificationId) 매핑 실패")
                    }
                }
                return (result, dto.isLast)
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
