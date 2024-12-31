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
    }
    enum Mutation {
        case setSendMatePost([SimplePost])
        case setError(PresentationError?)
    }
    struct State {
        var sendMates: [SimplePost] = []
        var error: PresentationError?
    }
    
    var initialState: State
    private let sendAppliesUsecase: LoadSendAppliesUseCase
    init(sendAppliesUsecase: LoadSendAppliesUseCase) {
        self.initialState = State()
        self.sendAppliesUsecase = sendAppliesUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadSendMate:
            return sendAppliesUsecase.execute()
                .flatMap { applies in
                    let posts = applies.map { $0.post }
                    return Observable.just(Mutation.setSendMatePost(posts))
                }
                .catch { error in
                    return Observable.just(Mutation.setError(error.toPresentationError()))
                }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setSendMatePost(let applies):
            newState.sendMates = applies
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
