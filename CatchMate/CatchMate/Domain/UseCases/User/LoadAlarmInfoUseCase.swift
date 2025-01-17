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
        return userRepository.loadUser()
            .map { user in
                return AlarmInfo(user: user)
            }
            .catch { error in
                return Observable.error(DomainError(error: error, context: .pageLoad))
            }
    }
}
