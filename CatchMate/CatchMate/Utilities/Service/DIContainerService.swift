//
//  DIContainerService.swift
//  CatchMate
//
//  Created by 방유빈 on 6/17/24.
//

import UIKit

class DIContainerService {
    static let shared = DIContainerService()

    private init() {}

//    func makeUserReactor() -> UserReactor {
//        let userRepository = UserRepositoryImpl()
//        let getUserUseCase = GetUserUseCaseImpl(userRepository: userRepository)
//        let addUserUseCase = AddUserUseCaseImpl(userRepository: userRepository)
//        let deleteUserUseCase = DeleteUserUseCaseImpl(userRepository: userRepository)
//        return UserReactor(getUserUseCase: getUserUseCase, addUserUseCase: addUserUseCase, deleteUserUseCase: deleteUserUseCase)
//    }
//
//    func makeUserViewController() -> UserViewController {
//        let viewController = UserViewController()
//        viewController.reactor = makeUserReactor()
//        return viewController
//    }
}
