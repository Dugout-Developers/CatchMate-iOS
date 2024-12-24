//
//  SetNotificationRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 12/20/24.
//

import UIKit
import RxSwift

final class SetNotificationRepositoryImpl: SetNotificationRepository {
    private let setNotificationDS: SetNotificationDataSource
    
    init(setNotificationDS: SetNotificationDataSource) {
        self.setNotificationDS = setNotificationDS
    }
    
    func setNotificationRepository(type: NotificationType, state: Bool) -> RxSwift.Observable<Bool> {
        return setNotificationDS.setNotification(type: type.rawValue, isEnabled: state ? "Y" : "N")
            .flatMap { dto -> Observable<Bool> in
                if dto.isEnabled == "Y" {
                    return Observable.just(true)
                } else if dto.isEnabled == "N" {
                    return Observable.just(false)
                } else {
                    return Observable.error(PresentationError.showToastMessage(message: "알람 설정에 실패했습니다.\n다시 시도해주세요."))
                }
            }
            .catch { error in
                return Observable.error(ErrorMapper.mapToPresentationError(error))
            }
    }
    
    
}
