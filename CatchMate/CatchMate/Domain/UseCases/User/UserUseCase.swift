//
//  UserUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

import UIKit
import RxSwift

protocol UserUseCase {
    func loadUser() -> Observable<User>
}

final class UserUseCaseImpl: UserUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func loadUser() -> Observable<User> {
        return userRepository.loadUser()
    }
}
