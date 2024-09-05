//
//  AuthService.swift
//  CatchMate
//
//  Created by 방유빈 on 8/1/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire


final class AuthManager {
    private let disposeBag = DisposeBag()
    private let tokenDS: TokenDataSource
    init(tokenDS: TokenDataSource) {
        self.tokenDS = tokenDS
    }
    deinit {
        print("AuthManager Deinit")
    }
    func attemptAutoLogin() -> Observable<Bool> {
        guard let refreshToken = tokenDS.getToken(for: .refreshToken) else {
            return Observable.just(false)
        }
        return APIService.shared.refreshAccessToken(refreshToken: refreshToken)
            .timeout(.seconds(10), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .flatMap { manager, newToken in
                print(newToken)
                if manager.tokenDS.saveToken(token: newToken, for: .accessToken) {
                    return Observable.just(true)
                }
                return Observable.just(false)
            }
            .catch { error in
                print("Error occurred: \(error)")
                return Observable.just(false)
            }
    }
}
