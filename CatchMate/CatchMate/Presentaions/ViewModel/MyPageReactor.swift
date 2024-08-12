//
//  MyPageReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

import UIKit
import RxSwift
import ReactorKit

final class MyPageReactor: Reactor {
    enum Action {
        case loadUser
        case logout
    }
    enum Mutation {
        case setLoading(Bool)
        case setUser(User)
        case setError(Error?)
        case logout(Bool)
    }
    struct State {
        var isLoading: Bool = false
        var user: User?
        var error: Error?
        var logoutResult: Bool = false
    }
    
    var initialState: State
    private let userUseCase: UserUseCase
    private let logoutUseCase: LogoutUseCase
    deinit {
        print("Logout Reactor deinit")
    }
    init(userUsecase: UserUseCase, logoutUsecase: LogoutUseCase) {
        self.initialState = State()
        self.userUseCase = userUsecase
        self.logoutUseCase = logoutUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadUser:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                userUseCase.loadUser()
                    .map { Mutation.setUser($0) }
                    .catch { .just(Mutation.setError($0)) },
                Observable.just(Mutation.setLoading(false))
            ])
        case .logout:
            guard let refreshToken = KeychainService.getToken(for: .refreshToken) else {
                return Observable.just(Mutation.setError(TokenError.notFoundRefreshToken))
            }
            return logoutUseCase.logout(token: refreshToken)
                .map { Mutation.logout($0) }
                .catch { .just(Mutation.setError($0))}
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setUser(let user):
            newState.user = user
            newState.error = nil
        case .setError(let error):
            newState.error = error
        case .logout(let result):
            newState.logoutResult = result
        }
        return newState
    }
}
