//
//  SignUpUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 7/24/24.
//

import UIKit
import RxSwift

protocol SignUpUseCase {
    func execute(_ model: LoginModel, signupInfo: SignUpModel, isAlarm: Bool) -> Observable<SignUpResponse>
}

final class SignUpUseCaseImpl: SignUpUseCase {
    private let repository: SignUpRepository
    private let alarmRepository: SetAlarmRepository
    
    init(repository: SignUpRepository, alarmRepository: SetAlarmRepository) {
        self.repository = repository
        self.alarmRepository = alarmRepository
    }
    
    func execute(_ model: LoginModel, signupInfo: SignUpModel, isAlarm: Bool) -> RxSwift.Observable<SignUpResponse> {
        LoggerService.shared.log(level: .info, "회원가입")
        return repository.requestSignup(model, signupInfo: signupInfo)
            .flatMap { response in
                return self.alarmRepository.setNotificationRepository(type: .event, state: isAlarm)
                    .map { _ in response } 
            }
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "회원가입하는데 문제가 발생했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "signup", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
