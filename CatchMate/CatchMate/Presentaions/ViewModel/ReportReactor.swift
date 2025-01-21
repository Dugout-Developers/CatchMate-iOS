//
//  ReportReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 10/3/24.
//

import RxSwift
import ReactorKit

final class ReportReactor: Reactor {
    enum Action {
        // TODO: - 차단 상태인지 확인하기
        case reportUser(Int)
    }
    enum Mutation {
        case setFinishedReport(Bool)
    }
    struct State {
        var finishedReport: Bool = false
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .reportUser(let userId):
            print(userId)
            return Observable.just(Mutation.setFinishedReport(true))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            
        case .setFinishedReport(let result):
            newState.finishedReport = result
        }
        return newState
    }
}
