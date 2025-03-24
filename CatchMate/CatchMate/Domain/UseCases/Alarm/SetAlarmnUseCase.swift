//
//  SetNotificationUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 12/20/24.
//

import UIKit
import RxSwift

protocol SetAlarmUseCase {
    func execute(type: AlarmnType, state: Bool) -> Observable<Bool>
}

final class SetAlarmUseCaseImpl: SetAlarmUseCase {
    private let setNotificationRepository: SetAlarmRepository
    
    init(setNotificationRepository: SetAlarmRepository) {
        self.setNotificationRepository = setNotificationRepository
    }
    
    func execute(type: AlarmnType, state: Bool) -> Observable<Bool> {
        LoggerService.shared.log(level: .info, "\(type.rawValue) 설정 \(state ? "On" : "off")")
        return setNotificationRepository.setNotificationRepository(type: type, state: state)
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "알람 설정하는데 문제가 발생했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "set_alarm", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
