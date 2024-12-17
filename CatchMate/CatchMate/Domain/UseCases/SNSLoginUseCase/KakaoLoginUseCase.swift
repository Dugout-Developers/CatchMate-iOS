//
//  KakaoLoginUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import RxSwift

protocol KakaoLoginUseCase {
    func execute() -> Observable<LoginModel>
}

final class KakaoLoginUseCaseImpl: KakaoLoginUseCase {
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
            snsRepository.kakaoLogin(),
            fcmRepository.getFCMToken()
        )
        .withUnretained(self)
        .flatMap { (usecase, arg1) -> Observable<LoginModel> in
            let (snsModel, token) = arg1
            return usecase.serverRepository.login(snsModel: snsModel, token: token)
        }
    }
}
