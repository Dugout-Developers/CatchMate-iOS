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
    
    func makeAuthReactor() -> Result<AuthReactor, Error> {
        do {
            let loginDS = try LoginDataSourceImpl()
            let repository = LoginRepositoryImpl(snsDataSource: SNSLoginDataSourceImpl(), fcmDataSource: FCMTokenDataSourceImpl(), loginDatasource: loginDS)
            let kakaoUsecase = KakaoLoginUseCaseImpl(repository: repository)
            let appleUsecase = AppleLoginUseCaseImpl(repository: repository)
            let naverUsecase = NaverLoginUseCaseeImpl(repository: repository)
            let reactor = AuthReactor(kakaoUsecase: kakaoUsecase, appleUsecase: appleUsecase, naverUsecase: naverUsecase)
            
            return .success(reactor)
        } catch {
            return .failure(error)
        }
    }
    
    func makeSignReactor(_ model: LoginModel) -> SignReactor {
        let dataSource = SignUpDataSourceImpl()
        let repository = SignUpRepositoryImpl(signupDatasource: dataSource)
        let usecase = SignUpUseCaseImpl(repository: repository)
        return SignReactor(loginModel: model, signupUseCase: usecase)
    }
}
