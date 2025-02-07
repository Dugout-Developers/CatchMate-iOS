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
        LoggerService.shared.log(level: .info, "내 정보 불러오기")
        return userRepository.loadUser()
            .catch { error in
                let domainError = DomainError(error: error, context: .tokenUnavailable)
                LoggerService.shared.errorLog(domainError, domain: "load_user", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}

