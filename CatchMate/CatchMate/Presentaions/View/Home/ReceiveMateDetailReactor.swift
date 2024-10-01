//
//  ReceiveMateDetailReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 8/11/24.
//

import RxSwift
import ReactorKit

final class ReceiveMateDetailReactor: Reactor {
    enum Action {
//        case accetApply(String)
//        case rejectApply(String)
    }
    enum Mutation {
//        case updateApplies([Apply])
//        case setError(PresentationError?)
    }
    
    struct State {
        var applies: [RecivedApplyData]
        var Error: PresentationError?
    }
    
    var initialState: State
    init(aplies: [RecivedApplyData]) {
        self.initialState = State(applies: aplies)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
//        case .accetApply(let id):
//            // MARK: - 신청 수락 로직 추가
//
//        case .rejectApply(let id):
//            
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
//        case .updateApplies(let applies):
//            newState.applies = applies
//            newState.Error = nil
//        case .setError(let error):
//            newState.Error = error
        }
        return newState
    }
}
