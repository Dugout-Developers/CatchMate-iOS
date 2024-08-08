//
//  SignRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//
import UIKit
import RxSwift


class SNSLoginRepositoryImpl: SNSLoginRepository {
    
    private let kakaoLoginDS: KakaoDataSourceImpl
    private let naverLoginDS: NaverLoginDataSourceImpl
    private let appleLoginDS: AppleLoginDataSourceImpl
    

    init(kakaoLoginDS: KakaoDataSourceImpl, naverLoginDS: NaverLoginDataSourceImpl, appleLoginDS: AppleLoginDataSourceImpl) {
        self.kakaoLoginDS = kakaoLoginDS
        self.naverLoginDS = naverLoginDS
        self.appleLoginDS = appleLoginDS
    }

    func kakaoLogin() -> RxSwift.Observable<SNSLoginResponse> {
        return kakaoLoginDS.getKakaoLoginToken()
            .catch { error in
                LoginUserDefaultsService.shared.deleteLoginData()
                return Observable.error(ErrorMapper.mapToPresentationError(error))
            }
    }
    
    func appleLogin() -> RxSwift.Observable<SNSLoginResponse> {
        return appleLoginDS.getAppleLoginToken()
            .catch { error in
                LoginUserDefaultsService.shared.deleteLoginData()
                return Observable.error(ErrorMapper.mapToPresentationError(error))
            }
    }
    
    func naverLogin() -> RxSwift.Observable<SNSLoginResponse> {
        return naverLoginDS.getNaverLoginToken()
            .catch { error in
                LoginUserDefaultsService.shared.deleteLoginData()
                return Observable.error(ErrorMapper.mapToPresentationError(error))
            }
    }
    
}
