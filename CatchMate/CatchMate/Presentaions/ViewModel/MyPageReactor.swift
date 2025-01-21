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
        case setCount(Int)
        case setError(PresentationError?)
        case logout(Bool)
    }
    struct State {
        var isLoading: Bool = false
        var user: User?
        var error: PresentationError?
        var count: Int = 0
        var logoutResult: Bool = false
    }
    
    var initialState: State
    private let userUseCase: LoadMyInfoUseCase
    private let loadReceivedCountUsecase: LoadReceivedCountUseCase
    private let logoutUseCase: LogoutUseCase
    deinit {
        print("Logout Reactor deinit")
    }
    
    init(userUsecase: LoadMyInfoUseCase, logoutUsecase: LogoutUseCase, loadReceivedCountUsecase: LoadReceivedCountUseCase) {
        self.initialState = State()
        self.userUseCase = userUsecase
        self.logoutUseCase = logoutUsecase
        self.loadReceivedCountUsecase = loadReceivedCountUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadUser:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                userUseCase.execute()
                    .map { Mutation.setUser($0) }
                    .catch { error in
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    },
                loadReceivedCountUsecase.execute()
                    .map{ Mutation.setCount($0) }
                    .catch { error in
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    },
                Observable.just(Mutation.setLoading(false))
            ])
        case .logout:
            return logoutUseCase.logout()
                .map { Mutation.logout($0) }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
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
        case .setCount(let count):
            newState.count = count
        }
        return newState
    }
}
