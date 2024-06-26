//
//  NaverLoginUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 6/30/24.
//

import RxSwift

protocol NaverLoginUseCase {
    func login() -> Observable<LoginModel>
}

final class NaverLoginUseCaseeImpl: NaverLoginUseCase {
    private let repository: SignRepository
    
    init(repository: SignRepository) {
        self.repository = repository
    }
    func login() -> Observable<LoginModel> {
        return repository.naverLogin()
    }
}
