//
//  NaverLoginUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 6/30/24.
//

import RxSwift

protocol NaverLoginUseCase {
    func execute() -> Observable<LoginModel>
}

final class NaverLoginUseCaseImpl: NaverLoginUseCase {
    private let snsRepository: SNSLoginRepository
    private let fcmRepository: FCMRepository
    private let serverRepository: ServerLoginRepository
    init(snsRepository: SNSLoginRepository, fcmRepository: FCMRepository, serverRepository: ServerLoginRepository) {
        self.snsRepository = snsRepository
        self.fcmRepository = fcmRepository
        self.serverRepository = serverRepository
    }
    func execute() -> RxSwift.Observable<LoginModel> {
        return Observable.zip(
            snsRepository.naverLogin(),
            fcmRepository.getFCMToken()
        )
        .withUnretained(self)
        .flatMap { (usecase, arg1) -> Observable<LoginModel> in
            let (snsModel, token) = arg1
            return usecase.serverRepository.login(snsModel: snsModel, token: token)
        }
        .catch { error in
            return Observable.error(DomainError(error: error, context: .action, message: "로그인에 실패했습니다.").toPresentationError())
        }
    }
}

