//
//  SetNotificationRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 12/20/24.
//
import UIKit
import RxSwift

protocol SetNotificationRepository {
    func setNotificationRepository(type: NotificationType, state: Bool) -> Observable<Bool>
}

