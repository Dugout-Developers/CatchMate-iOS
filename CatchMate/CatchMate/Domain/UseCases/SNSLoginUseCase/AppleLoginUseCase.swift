//
//  AppleLoginUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 6/28/24.
//

import RxSwift

protocol AppleLoginUseCase {
    func login() -> Observable<LoginModel>
}

final class AppleLoginUseCaseImpl: AppleLoginUseCase {
    private let repository: LoginRepository
    
    init(repository: LoginRepository) {
        self.repository = repository
    }
    func login() -> RxSwift.Observable<LoginModel> {
        return repository.appleLogin()
    }
}
