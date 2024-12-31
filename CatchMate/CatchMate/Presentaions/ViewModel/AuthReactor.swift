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
        case resetState
        case kakaoLogin
        case appleLogin
        case naverLogin
        case setError(PresentationError?)
    }
    enum Mutation {
        case resetState
        case setLoginInfo(LoginModel)
        case setError(PresentationError?)
    }
    struct State {
        var loginModel: LoginModel?
        var error: PresentationError?
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
            return kakaoLoginUseCase.execute()
                .map { loginModel in
                    return Mutation.setLoginInfo(loginModel)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(error.toPresentationError()))
                }
        case .appleLogin:
            return appleLoginUseCase.execute()
                .map { loginModel in
                    return Mutation.setLoginInfo(loginModel)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(error.toPresentationError()))
                }
        case .naverLogin:
            return naverLoginUseCase.execute()
                .map { loginModel in
                    return Mutation.setLoginInfo(loginModel)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(error.toPresentationError()))
                }
            
        case .setError(let error):
            return Observable.just(Mutation.setError(error))
        case .resetState:
            URLCache.shared.removeAllCachedResponses()
            return Observable.just(Mutation.resetState)
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoginInfo(let loginModel):
            newState.loginModel = loginModel
            if !loginModel.isFirstLogin {
                if !saveToken(loginModel: loginModel) {
                    newState.error = PresentationError.showToastMessage(message: "로그인 실패")
                }
            }
        case .setError(let error):
            newState.error = error
        case .resetState:
            newState.loginModel = nil
            newState.error = nil
        }
        return newState
    }
    
    private func saveToken(loginModel: LoginModel) -> Bool {
        if let accessToken = loginModel.accessToken, let refreshToken = loginModel.refreshToken {
            LoggerService.shared.debugLog("saveKeychain : \(accessToken), \(refreshToken)")
            UnauthorizedErrorHandler.shared.handleError()
            return true
        } else {
            return false
        }
    }
}
