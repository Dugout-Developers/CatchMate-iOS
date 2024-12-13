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
    func loadCount() -> Observable<Int>
}

final class UserUseCaseImpl: UserUseCase {
    private let userRepository: UserRepository
    private let loadCountRepository: ReceivedCountRepository
    
    init(userRepository: UserRepository, loadCountRepository: ReceivedCountRepository) {
        self.userRepository = userRepository
        self.loadCountRepository = loadCountRepository
    }
    
    func loadUser() -> Observable<User> {
        return userRepository.loadUser()
    }
    func loadCount() -> Observable<Int> {
        return loadCountRepository.loadCount()
    }
}
