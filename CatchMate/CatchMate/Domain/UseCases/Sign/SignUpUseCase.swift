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
    func execute(_ model: LoginModel, signupInfo: SignUpModel) -> RxSwift.Observable<SignUpResponse> {
        return repository.requestSignup(model, signupInfo: signupInfo)
    }
    
    private let repository: SignUpRepository
    
    init(repository: SignUpRepository) {
        self.repository = repository
    }

}
