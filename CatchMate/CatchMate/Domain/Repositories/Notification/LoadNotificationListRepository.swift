//
//  LoadNotificationListRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 1/7/25.
//
import UIKit
import RxSwift

protocol LoadNotificationListRepository {
    func loadNotificationList() -> Observable<[NotificationList]>
}
