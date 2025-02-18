//
//  LoadBlockUsersRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 2/17/25.
//

import UIKit
import RxSwift

final class LoadBlockUsersRepositoryImpl: LoadBlockUsersRepository {
    private let loadBlockUserDS: LoadBlockUsersDataSource
    init(loadBlockUserDS: LoadBlockUsersDataSource) {
        self.loadBlockUserDS = loadBlockUserDS
    }
    
    func loadBlockUsers(page: Int) -> RxSwift.Observable<(users: [SimpleUser], isLast: Bool)> {
        return loadBlockUserDS.loadBlockUsers(page: page)
            .map { dto in
                let userMapper = UserMapper()
                var users = [SimpleUser]()
                for user in dto.userInfoList {
                    guard let mappingUser = userMapper.dtoToDomain(user) else {
                        LoggerService.shared.log("(\(user.userId))\(user.nickName) 변환 실패")
                        continue
                    }
                    users.append(mappingUser)
                }
                return (users, dto.isLast)
            }
    }
}
