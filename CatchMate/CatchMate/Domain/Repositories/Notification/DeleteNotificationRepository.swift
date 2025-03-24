//
//  DeleteNotificationRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 1/8/25.
//

import UIKit
import RxSwift

protocol DeleteNotificationRepository {
    func deleteNotification(notificationId: Int) -> Observable<Bool>
}
