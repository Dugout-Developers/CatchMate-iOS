//
//  LoadBlockUsersRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 2/17/25.
//

import UIKit
import RxSwift

protocol LoadBlockUsersRepository {
    func loadBlockUsers(page: Int) -> Observable<(users: [SimpleUser], isLast: Bool)>
}
