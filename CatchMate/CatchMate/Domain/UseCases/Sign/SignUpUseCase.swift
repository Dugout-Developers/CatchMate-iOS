//
//  SignUpUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 7/24/24.
//

import UIKit
import RxSwift

protocol SignUpUseCase {
    func signup(_ model: SignUpModel) -> Observable<Result<SignUpResponse, SignUpAPIError>>
}

final class SignUpUseCaseImpl: SignUpUseCase {
    private let repository: SignUpRepository
    
    init(repository: SignUpRepository) {
        self.repository = repository
    }
    func signup(_ model: SignUpModel) -> RxSwift.Observable<Result<SignUpResponse, SignUpAPIError>> {
        return repository.requestSignUp(model)
    }
}
