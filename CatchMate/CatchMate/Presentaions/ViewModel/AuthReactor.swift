//
//  AuthReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 7/23/24.
//

import UIKit
import ReactorKit
import RxSwift

final class AuthReactor: Reactor {
    enum Action {
        case kakaoLogin
        case appleLogin
        case naverLogin
    }
    enum Mutation {
        case setLoginInfo(LoginModel)
        case setAuthenticated(Bool)
    }
    struct State {
        var loginModel: LoginModel?
        var isAuthenticated: Bool = false
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
                    self.saveTokens(loginModel)
                    return Mutation.setLoginInfo(loginModel)
                }
                .catchAndReturn(Mutation.setAuthenticated(false))
        case .appleLogin:
            return appleLoginUseCase.login()
                .map { loginModel in
                    self.saveTokens(loginModel)
                    return Mutation.setLoginInfo(loginModel)
                }
                .catchAndReturn(Mutation.setAuthenticated(false))
        case .naverLogin:
            return naverLoginUseCase.login()
                .map { loginModel in
                    self.saveTokens(loginModel)
                    return Mutation.setLoginInfo(loginModel)
                }
                .catchAndReturn(Mutation.setAuthenticated(false))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoginInfo(let loginModel):
            newState.loginModel = loginModel
            newState.isAuthenticated = !loginModel.isFirstLogin
        case .setAuthenticated(let state):
            newState.isAuthenticated = state
        }
        return newState
    }
    private func saveTokens(_ loginModel: LoginModel) {
        // TODO: - KeyChain 연결 로직
//        keychainService.saveAccessToken(loginModel.accessToken)
//        keychainService.saveRefreshToken(loginModel.refreshToken)
    }
}
