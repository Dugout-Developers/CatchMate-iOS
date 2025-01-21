//
//  SignUpUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 7/24/24.
//

import UIKit
import RxSwift

protocol SignUpUseCase {
    func execute(_ model: LoginModel, signupInfo: SignUpModel) -> Observable<SignUpResponse>
}

final class SignUpUseCaseImpl: SignUpUseCase {
    private let repository: SignUpRepository
    
    init(repository: SignUpRepository) {
        self.repository = repository
    }
    
    func execute(_ model: LoginModel, signupInfo: SignUpModel) -> RxSwift.Observable<SignUpResponse> {
        return repository.requestSignup(model, signupInfo: signupInfo)
            .catch { error in
                return Observable.error(DomainError(error: error, context: .action, message: "회원가입하는데 문제가 발생했습니다."))
            }
    }
}
