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
    private let tokenDS: TokenDataSource
    init(kakaoUsecase: KakaoLoginUseCase, appleUsecase: AppleLoginUseCase, naverUsecase: NaverLoginUseCase, tokenDS: TokenDataSource) {
        self.initialState = State()
        self.kakaoLoginUseCase = kakaoUsecase
        self.appleLoginUseCase = appleUsecase
        self.naverLoginUseCase = naverUsecase
        self.tokenDS = tokenDS
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .kakaoLogin:
            return kakaoLoginUseCase.execute()
                .map { loginModel in
                    return Mutation.setLoginInfo(loginModel)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .appleLogin:
            return appleLoginUseCase.execute()
                .map { loginModel in
                    return Mutation.setLoginInfo(loginModel)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .naverLogin:
            return naverLoginUseCase.execute()
                .map { loginModel in
                    return Mutation.setLoginInfo(loginModel)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
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
            if !tokenDS.saveToken(token: accessToken, for: .accessToken) {
                LoggerService.shared.debugLog("accessToken KeyChain저장 실패")
            }
            if !tokenDS.saveToken(token: refreshToken, for: .refreshToken) {
                LoggerService.shared.debugLog("refreshToken KeyChain저장 실패")
            }
            return true
        } else {
            return false
        }
    }
}
