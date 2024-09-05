//
//  RecevieMateReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 8/8/24.
//

import RxSwift
import ReactorKit

final class RecevieMateReactor: Reactor {
    enum Action {
        case loadReceiveMate
        case selectPost([ApplyList]?)
//        case deleteApply(String)
//        case applyMate(String)
    }
    enum Mutation {
        case setReceiveMate([[Apply]])
        case setSelectedPost([Apply]?)
        case setError(PresentationError?)
    }
    struct State {
        var receiveMates: [[Apply]] = []
        var selectedPost: [Apply]?
        var error: PresentationError?
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadReceiveMate:
            return Observable.just(Mutation.setReceiveMate(Apply.recevieDummyData))
//        case .deleteApply(let id):
//            
//        case .applyMate(let id):
//
        case .selectPost(let apply):
            return Observable.just(Mutation.setSelectedPost(apply))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setReceiveMate(let applies):
            newState.receiveMates = applies
        case .setError(let error):
            newState.error = error
        case .setSelectedPost(let apply):
            newState.selectedPost = apply
        }
        return newState
    }
}
