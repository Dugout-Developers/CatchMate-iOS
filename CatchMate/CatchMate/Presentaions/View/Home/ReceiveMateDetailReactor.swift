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
        case accetApply(String)
        case rejectApply(String)
    }
    enum Mutation {
        case updateApplies([Apply])
        case setError(PresentationError?)
    }
    
    struct State {
        var applies: [Apply]
        var Error: PresentationError?
    }
    
    var initialState: State
    init(aplies: [Apply]) {
        self.initialState = State(applies: aplies)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .accetApply(let id):
            // MARK: - 신청 수락 로직 추가
            var tempApplies = currentState.applies
            if let index = currentState.applies.firstIndex(where: { $0.id == id }) {
                tempApplies.remove(at: index)
                return Observable.just(Mutation.updateApplies(tempApplies))
            } else {
                return Observable.just(Mutation.setError(PresentationError.informational(message: "처리에 문제가 생겼습니다.")))
            }
            
        case .rejectApply(let id):
            var tempApplies = currentState.applies
            if let index = currentState.applies.firstIndex(where: { $0.id == id }) {
                tempApplies.remove(at: index)
                return Observable.just(Mutation.updateApplies(tempApplies))
            } else {
                return Observable.just(Mutation.setError(PresentationError.informational(message: "처리에 문제가 생겼습니다.")))
            }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .updateApplies(let applies):
            newState.applies = applies
            newState.Error = nil
        case .setError(let error):
            newState.Error = error
        }
        return newState
    }
}
