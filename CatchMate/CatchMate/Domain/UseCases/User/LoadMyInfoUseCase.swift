//
//  UserUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

import UIKit
import RxSwift

protocol LoadMyInfoUseCase {
    func execute() -> Observable<User>
}

final class UserUseCaseImpl: LoadMyInfoUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute() -> Observable<User> {
        return userRepository.loadUser()
            .catch { error in
                return Observable.error(DomainError(error: error, context: .tokenUnavailable).toPresentationError())
            }
    }
}

