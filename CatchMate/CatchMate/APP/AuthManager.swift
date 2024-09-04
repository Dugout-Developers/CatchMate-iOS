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
    private let userDataSource: UserDataSource
    
    init(userDataSource: UserDataSource) {
        self.userDataSource = userDataSource
    }
    
    func attemptAutoLogin() -> Observable<Bool> {
        return userDataSource.loadMyInfo()
            .flatMap { _ -> Observable<Bool> in
                return Observable.just(true)
            }
            .catch { error in
                LoggerService.shared.debugLog("자동 로그인 에러: - \(error)")
                return Observable.just(false)
            }
    }
}
