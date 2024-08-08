//
//  SendMateReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 8/8/24.
//

import RxSwift
import ReactorKit

final class SendMateReactor: Reactor {
    enum Action {
        case loadSendMate
        case cancelApply(String)
    }
    enum Mutation {
        case setSendMate([Apply])
        case setError(PresentationError?)
    }
    struct State {
        var sendMates: [Apply] = []
        var error: PresentationError?
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadSendMate:
            return Observable.just(Mutation.setSendMate(Apply.dummyData))
        case .cancelApply(let id):
            if let index = Apply.dummyData.firstIndex(where: {$0.id == id}) {
                Apply.dummyData.remove(at: index)
            }
            return Observable.just(Mutation.setSendMate(Apply.dummyData))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setSendMate(let applies):
            newState.sendMates = applies
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
