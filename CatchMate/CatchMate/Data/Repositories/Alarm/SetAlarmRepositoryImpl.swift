//
//  SetNotificationRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 12/20/24.
//

import UIKit
import RxSwift

final class SetAlarmRepositoryImpl: SetAlarmRepository {
    private let setNotificationDS: SetAlarmDataSource
    
    init(setNotificationDS: SetAlarmDataSource) {
        self.setNotificationDS = setNotificationDS
    }
    
    func setNotificationRepository(type: AlarmnType, state: Bool) -> RxSwift.Observable<Bool> {
        return setNotificationDS.setNotification(type: type.rawValue, isEnabled: state ? "Y" : "N")
            .flatMap { dto -> Observable<Bool> in
                if dto.isEnabled == "Y" {
                    return Observable.just(true)
                } else if dto.isEnabled == "N" {
                    return Observable.just(false)
                } else {
                    return Observable.error(MappingError.invalidData)
                }
            }
    }
    
    
}
