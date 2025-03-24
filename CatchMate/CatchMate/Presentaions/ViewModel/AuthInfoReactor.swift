//
//  AuthInfoReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 3/9/25.
//
import RxSwift
import ReactorKit
final class AuthInfoReactor: Reactor {
    enum Action {
        case logout
        case withdraw
    }
    enum Mutation {
        case setEventTrigger
        case setError(PresentationError?)
    }
    struct State {
        // View의 state를 관리한다.
        var eventTrigger: Bool = false
        var error: PresentationError?
    }
    
    var initialState: State
    
    private let logoutUseCase: LogoutUseCase
    private let withdrawUseCase: WithdrawUseCase
    init(logoutUseCase: LogoutUseCase, withdrawUseCase: WithdrawUseCase) {
        self.initialState = State()
        self.logoutUseCase = logoutUseCase
        self.withdrawUseCase = withdrawUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .logout:
            return logoutUseCase.logout()
                .map { state in
                    if state {
                        return .setEventTrigger
                    } else {
                        return .setError(.showToastMessage(message: "로그아웃에 실패했어요"))
                    }
                }
                .catch { error in
                    return Observable.just(.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .withdraw:
            return withdrawUseCase.withdraw()
                .map { _ in
                    return .setEventTrigger
                }
                .catch { error in
                    return Observable.just(.setError(ErrorMapper.mapToPresentationError(error)))
                }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.error = nil
        switch mutation {
        case .setEventTrigger:
            newState.eventTrigger = true
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
