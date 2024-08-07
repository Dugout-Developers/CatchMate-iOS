//
//  AuthReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 7/23/24.
//

import UIKit
import ReactorKit
import RxSwift
import NaverThirdPartyLogin

final class AuthReactor: Reactor {
    enum Action {
        case kakaoLogin
        case appleLogin
        case naverLogin
        case setError(Error)
    }
    enum Mutation {
        case setLoginInfo(LoginModel)
        case setError(Error)
    }
    struct State {
        var loginModel: LoginModel?
        var errorMessage: String?
    }
    
    var initialState: State
    private let kakaoLoginUseCase: KakaoLoginUseCase
    private let appleLoginUseCase: AppleLoginUseCase
    private let naverLoginUseCase: NaverLoginUseCase
    
    init(kakaoUsecase: KakaoLoginUseCase, appleUsecase: AppleLoginUseCase, naverUsecase: NaverLoginUseCase) {
        self.initialState = State()
        self.kakaoLoginUseCase = kakaoUsecase
        self.appleLoginUseCase = appleUsecase
        self.naverLoginUseCase = naverUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .kakaoLogin:
            return kakaoLoginUseCase.login()
                .map { loginModel in
                    return Mutation.setLoginInfo(loginModel)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(error))
                }
        case .appleLogin:
            return appleLoginUseCase.login()
                .map { loginModel in
                    return Mutation.setLoginInfo(loginModel)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(error))
                }
        case .naverLogin:
            return naverLoginUseCase.login()
                .map { loginModel in
                    return Mutation.setLoginInfo(loginModel)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(error))
                }
            
        case .setError(let error):
            return Observable.just(Mutation.setError(error))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoginInfo(let loginModel):
            saveToken(loginModel: loginModel)
            newState.loginModel = loginModel
        case .setError(let error):
            print(error.localizedDescription)
            newState.errorMessage = error.localizedDescription
        }
        return newState
    }
    private func saveToken(loginModel: LoginModel) {
        LoggerService.shared.debugLog("saveKeychain : \(loginModel.accessToken), \(loginModel.refreshToken)")
        KeychainService.saveToken(token: loginModel.accessToken, for: .accessToken)
        KeychainService.saveToken(token: loginModel.refreshToken, for: .refreshToken)
    }
}
