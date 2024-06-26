//
//  KakaoLoginUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import RxSwift

protocol KakaoLoginUseCase {
    func login() -> Observable<LoginModel>
}

final class KakaoLoginUseCaseImpl: KakaoLoginUseCase {
    private let repository: SignRepository
    
    init(repository: SignRepository) {
        self.repository = repository
    }
    func login() -> RxSwift.Observable<LoginModel> {
        return repository.kakaoLogin()
    }
}
