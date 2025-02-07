//
//  AppleLoginUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 6/28/24.
//

import RxSwift

protocol AppleLoginUseCase {
    func execute() -> Observable<LoginModel>
}

final class AppleLoginUseCaseImpl: AppleLoginUseCase {
    private let snsRepository: SNSLoginRepository
    private let fcmRepository: FCMRepository
    private let serverRepository: ServerLoginRepository
    init(snsRepository: SNSLoginRepository, fcmRepository: FCMRepository, serverRepository: ServerLoginRepository) {
        self.snsRepository = snsRepository
        self.fcmRepository = fcmRepository
        self.serverRepository = serverRepository
    }
    func execute() -> RxSwift.Observable<LoginModel> {
        LoggerService.shared.log(level: .info, "애플 로그인 시도")
        return Observable.zip(
            snsRepository.appleLogin(),
            fcmRepository.getFCMToken()
        )
        .withUnretained(self)
        .flatMap { (usecase, arg1) -> Observable<LoginModel> in
            let (snsModel, token) = arg1
            return usecase.serverRepository.login(snsModel: snsModel, token: token)
        }
        .catch { error in
            let domainError = DomainError(error: error, context: .action, message: "로그인에 문제가 발생했습니다.")
            LoggerService.shared.errorLog(domainError, domain: "applelogin", message: error.errorDescription)
            return Observable.error(domainError)
        }
    }
}
