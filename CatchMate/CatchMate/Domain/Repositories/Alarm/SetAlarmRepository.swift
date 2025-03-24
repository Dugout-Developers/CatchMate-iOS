//
//  SetNotificationRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 12/20/24.
//
import UIKit
import RxSwift

protocol SetAlarmRepository {
    func setNotificationRepository(type: AlarmnType, state: Bool) -> Observable<Bool>
}

