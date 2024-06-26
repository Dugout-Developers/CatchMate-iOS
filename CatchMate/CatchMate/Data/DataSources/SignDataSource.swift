//
//  SignDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import UIKit
import RxSwift
import RxKakaoSDKCommon
import RxKakaoSDKUser
import KakaoSDKUser

protocol SignDataSource {
    func getKakaoLoginToken() -> Observable<KakaoLoginResponse>
}

class SignDataSourceImpl: SignDataSource {
    func getKakaoLoginToken() -> Observable<KakaoLoginResponse> {
        return Observable.create { observer in
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    observer.onError(error)
                } else if oauthToken != nil {
                    print("============================")
                    print("얍\(oauthToken)")
                    // 사용자 정보 요청
                    UserApi.shared.me { (user, error) in
                        if let error = error {
                            observer.onError(error)
                        } else if let user = user {
                            // 필요한 정보를 KakaoLoginResponse로 변환하여 observer에 전달
                            print("user:\(user)")
                            print("============================")
                            let response = KakaoLoginResponse(id: "\(String(describing: user.id))",
                                                              name: user.kakaoAccount?.profile?.nickname ?? "",
                                                              email: user.kakaoAccount?.email ?? "")
                            observer.onNext(response)
                            observer.onCompleted()
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }
}
