//
//  UserRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

import UIKit
import RxSwift

protocol UserRepository {
    func loadUser() -> Observable<User>
}
