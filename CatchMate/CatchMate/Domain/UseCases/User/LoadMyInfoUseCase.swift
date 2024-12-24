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
// loadCount -> 받은 신청 갯수 load 분리하고 상위 유즈케이스로 분리
final class UserUseCaseImpl: LoadMyInfoUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute() -> Observable<User> {
        return userRepository.loadUser()
    }
}

