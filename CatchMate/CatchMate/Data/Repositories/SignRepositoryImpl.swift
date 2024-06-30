//
//  SignRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//
import UIKit
import RxSwift


class SignRepositoryImpl: SignRepository {
    
    private let remoteDataSource: SignDataSourceImpl

    init(remoteDataSource: SignDataSourceImpl) {
        self.remoteDataSource = remoteDataSource
    }
    func kakaoLogin() -> Observable<LoginModel> {
        return remoteDataSource.getKakaoLoginToken()
            .map { response in
                // response를 User로 매핑
                return LoginModel(id: response.id, email: response.email)
            }
    }
    
    func appleLogin() -> Observable<LoginModel> {
        return remoteDataSource.getAppleLoginToken()
            .map { response in
                return LoginModel(id: response.id, email: response.email)
            }
    }
    
    func naverLogin() -> Observable<LoginModel> {
        return remoteDataSource.getNaverLoginToken()
            .map { response in
                return LoginModel(id: response.id, email: response.email)
            }
    }
}
