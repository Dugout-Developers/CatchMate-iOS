//
//  KakaoDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 7/27/24.
//

import UIKit
import RxSwift
import KakaoSDKCommon
import RxKakaoSDKCommon
import KakaoSDKAuth
import RxKakaoSDKAuth
import KakaoSDKUser
import RxKakaoSDKUser

protocol KakaoDataSource {
    func getKakaoLoginToken() -> Observable<SNSLoginResponse>
}

final class KakaoDataSourceImpl: NSObject, KakaoDataSource {
    private let disposeBag = DisposeBag()
    override init() {

        super.init()
    }
    // MARK: - KAKAO LOGIN
    enum LoginError: Error {
        case kakaoLoginFailed
        case missingUserInfo
    }
    
    func getKakaoLoginToken() -> Observable<SNSLoginResponse> {
        return Observable.create { observer -> Disposable in
            // Check if KakaoTalk is available
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                    if let error = error {
                        observer.onError(error)
                    } else {
                        // Successful login
                        guard let oauthToken = oauthToken else {
                            observer.onError(LoginError.kakaoLoginFailed)
                            return
                        }
                        self?.fetchUserInfo(oauthToken: oauthToken.accessToken, observer: observer)
                    }
                }
            } else {
                // Login via Kakao Account
                UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                    if let error = error {
                        observer.onError(error)
                    } else {
                        // Successful login
                        guard let oauthToken = oauthToken else {
                            observer.onError(LoginError.kakaoLoginFailed)
                            return
                        }
                        self?.fetchUserInfo(oauthToken: oauthToken.accessToken, observer: observer)
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    private func fetchUserInfo(oauthToken: String, observer: AnyObserver<SNSLoginResponse>) {
        UserApi.shared.me(propertyKeys: ["properties.nickname", "properties.profile_image"]) { user, error in
            if let error = error {
                observer.onError(error)
            } else {
                guard let user = user,
                      let id = user.id,
                      let email = user.kakaoAccount?.email else {
                    observer.onError(LoginError.missingUserInfo)
                    return
                }
                let loginResponse = SNSLoginResponse(id: String(id), email: email, loginType: .kakao, nickName: user.kakaoAccount?.profile?.nickname, image: user.kakaoAccount?.profile?.profileImageUrl?.absoluteString)
                
                observer.onNext(loginResponse)
                observer.onCompleted()
            }
        }
    }

}
