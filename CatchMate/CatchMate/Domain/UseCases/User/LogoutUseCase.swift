//
//  LogoutUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

import UIKit
import RxSwift

protocol LogoutUseCase {
    func logout(token: String) -> Observable<Bool>
}

final class LogoutUseCaseImpl: LogoutUseCase {
    private let repository: LogoutRepository
    
    init(repository: LogoutRepository) {
        self.repository = repository
    }
    func logout(token: String) -> RxSwift.Observable<Bool> {
        return repository.logout(token: token)
    }
    
}

