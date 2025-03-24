//
//  DeleteNotificationRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 1/8/25.
//

import RxSwift

final class DeleteNotificationRepositoryImpl: DeleteNotificationRepository {
    private let deleteNotiDS: DeleteNotificationDataSource
    init(deleteNotiDS: DeleteNotificationDataSource) {
        self.deleteNotiDS = deleteNotiDS
    }
    
    func deleteNotification(notificationId: Int) -> Observable<Bool> {
        return deleteNotiDS.deleteNotification(notificationId)
    }
}
