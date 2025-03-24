//
//  LoadNotificationIfoUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 12/19/24.
//

import UIKit
import RxSwift

protocol LoadAlarmInfoUseCase {
    func loadNotificationInfo() -> Observable<AlarmInfo>
}

final class LoadAlarmUseCaseImpl: LoadAlarmInfoUseCase {
    private let userRepository: UserRepository
   
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func loadNotificationInfo() -> Observable<AlarmInfo> {
        LoggerService.shared.log(level: .info, "알림 정보 불러오기")
        return userRepository.loadUser()
            .map { user in
                return AlarmInfo(user: user)
            }
            .catch { error in
                let domainError = DomainError(error: error, context: .pageLoad)
                LoggerService.shared.errorLog(domainError, domain: "load_alarminfo", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
