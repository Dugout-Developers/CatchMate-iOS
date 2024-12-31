//
//  LoadNotificationIfoUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 12/19/24.
//

import UIKit
import RxSwift

protocol LoadNotificationInfoUseCase {
    func loadNotificationInfo() -> Observable<NotificationInfo>
}

final class LoadNotificationUseCaseImpl: LoadNotificationInfoUseCase {
    private let userRepository: UserRepository
   
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func loadNotificationInfo() -> Observable<NotificationInfo> {
        return userRepository.loadUser()
            .map { user in
                return NotificationInfo(user: user)
            }
            .catch { error in
                return Observable.error(DomainError(error: error, context: .pageLoad).toPresentationError())
            }
    }
}
