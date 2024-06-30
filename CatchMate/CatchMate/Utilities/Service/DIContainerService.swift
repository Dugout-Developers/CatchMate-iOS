//
//  DIContainerService.swift
//  CatchMate
//
//  Created by 방유빈 on 6/17/24.
//

import UIKit

class DIContainerService {
    static let shared = DIContainerService()

    private init() {}

    func makeSignReactor() -> SignReactor {
        let repository = SignRepositoryImpl(remoteDataSource: SignDataSourceImpl())
        let kakaoUsecase = KakaoLoginUseCaseImpl(repository: repository)
        let appleUsecase = AppleLoginUseCaseImpl(repository: repository)
        let naverUsecase = NaverLoginUseCaseeImpl(repository: repository)
        let reactor = SignReactor(kakaoUsecase: kakaoUsecase, appleUsecase: appleUsecase, naverUsecase: naverUsecase)
        
        return reactor
    }
}
