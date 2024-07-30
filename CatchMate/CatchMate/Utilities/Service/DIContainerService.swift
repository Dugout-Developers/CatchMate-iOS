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
    
    func makeAuthReactor() -> AuthReactor{
        let naverDS = NaverLoginDataSourceImpl()
        let kakaoDS = KakaoDataSourceImpl()
        let appleDS = AppleLoginDataSourceImpl()
        let fcmDS = FCMTokenDataSourceImpl()
        let serverDS = ServerLoginDataSourceImpl()
        let loginRep = SNSLoginRepositoryImpl(kakaoLoginDS: kakaoDS, naverLoginDS: naverDS, appleLoginDS: appleDS)
        let fcmRep = FCMRepositoryImpl(fcmTokenDS: fcmDS)
        let serverRep = ServerLoginRepositoryImpl(serverLoginDS: serverDS)
        let kakaoUC = KakaoLoginUseCaseImpl(snsRepository: loginRep, fcmRepository: fcmRep, serverRepository: serverRep)
        let naverUC = NaverLoginUseCaseImpl(snsRepository: loginRep, fcmRepository: fcmRep, serverRepository: serverRep)
        let appleUC = AppleLoginUseCaseImpl(snsRepository: loginRep, fcmRepository: fcmRep, serverRepository: serverRep)
        let reactor = AuthReactor(kakaoUsecase: kakaoUC, appleUsecase: appleUC, naverUsecase: naverUC)
        
        return reactor
    }
    
    func makeSignReactor(_ model: LoginModel) -> SignReactor {
        let dataSource = SignUpDataSourceImpl()
        let repository = SignUpRepositoryImpl(signupDatasource: dataSource)
        let usecase = SignUpUseCaseImpl(repository: repository)
        return SignReactor(loginModel: model, signupUseCase: usecase)
    }
}
