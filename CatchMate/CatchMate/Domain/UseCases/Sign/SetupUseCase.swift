//
//  SetupUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/27/24.
//

import UIKit
import RxSwift

protocol SetupUseCase {
    func setupInfo() -> Observable<SetupResult>
}

final class SetupUseCaseImpl: SetupUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func setupInfo() -> RxSwift.Observable<SetupResult> {
        return userRepository.loadUser()
        .map { user -> SetupResult in
            return SetupResult(user: user)
        }
        .catch { error in
            return Observable.error(DomainError(error: error, context: .tokenUnavailable))
        }
    }
}
