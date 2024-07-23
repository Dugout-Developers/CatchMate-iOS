//
//  SignRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//
import UIKit
import RxSwift


class LoginRepositoryImpl: LoginRepository {
    
    private let snsLoginDataSource: SNSLoginDataSourceImpl
    private let fcmDataSource: FCMTokenDataSourceImpl
    private let loginDataSource: LoginDataSourceImpl

    init(snsDataSource: SNSLoginDataSourceImpl, fcmDataSource: FCMTokenDataSourceImpl, loginDatasource: LoginDataSourceImpl) {
        self.snsLoginDataSource = snsDataSource
        self.fcmDataSource = fcmDataSource
        self.loginDataSource = loginDatasource
    }
    func kakaoLogin() -> Observable<LoginModel> {
        return Observable.zip(snsLoginDataSource.getKakaoLoginToken(), fcmDataSource.getFcmToken())
            .flatMap { (snsResponse, fcmToken) -> Observable<LoginModel> in
                return self.loginDataSource.postLoginRequest(snsResponse, fcmToken)
            }
    }
    
    func appleLogin() -> Observable<LoginModel> {
        return Observable.zip(snsLoginDataSource.getAppleLoginToken(), fcmDataSource.getFcmToken())
            .flatMap { (snsResponse, fcmToken) -> Observable<LoginModel> in
                return self.loginDataSource.postLoginRequest(snsResponse, fcmToken)
            }
    }
    
    func naverLogin() -> Observable<LoginModel> {
        return Observable.zip(snsLoginDataSource.getNaverLoginToken(), fcmDataSource.getFcmToken())
            .flatMap { (snsResponse, fcmToken) -> Observable<LoginModel> in
                return self.loginDataSource.postLoginRequest(snsResponse, fcmToken)
            }
    }
}
