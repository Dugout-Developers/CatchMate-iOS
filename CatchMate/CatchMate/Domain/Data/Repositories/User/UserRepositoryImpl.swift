//
//  UserRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

import UIKit
import RxSwift

final class UserRepositoryImpl: UserRepository {
    private let userDS: UserDataSource
    
    init(userDS: UserDataSource) {
        self.userDS = userDS
    }
    
    func loadUser() -> Observable<User> {
        return userDS.loadMyInfo()
            .map { dto -> User in
                return UserMapper().userToDomain(dto)
            }
    }
}
