//
//  LoadNotificationListRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 1/7/25.
//

import UIKit
import RxSwift

final class LoadNotificationListRepositoryImpl: LoadNotificationListRepository {
    private let loadNotificationDS: NotificationListDataSource
    
    init(loadNotificationDS: NotificationListDataSource) {
        self.loadNotificationDS = loadNotificationDS
    }
    
    func loadNotificationList() -> RxSwift.Observable<[NotificationList]> {
        return loadNotificationDS.loadNotificationList()
            .map { dtoList in
                var result = [NotificationList]()
                for dto in dtoList {
                    if let notification = NotificationMapper.dtoToDomain(dto) {
                        result.append(notification)
                    }
                }
                return result
            }
    }
}
