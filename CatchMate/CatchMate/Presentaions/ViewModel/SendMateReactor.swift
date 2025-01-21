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
        case loadNextPage
    }
    enum Mutation {
        case setSendMatePost(list: [SimplePost], isAppend: Bool)
        case resetPage
        case incrementPage
        case setIsLast(Bool)
        case setLoading(Bool)
        case setError(PresentationError?)
    }
    struct State {
        var sendMates: [SimplePost] = []
        var currentPage: Int = 0
        var isLast: Bool = true
        var isLoading: Bool = true
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
            return sendAppliesUsecase.execute(page: 0)
                .flatMap { data -> Observable<Mutation> in
                    let posts = data.applys.map { $0.post }
                    return Observable.concat([
                        Observable.just(Mutation.setLoading(true)),
                        Observable.just(.setSendMatePost(list: posts, isAppend: false)),
                        Observable.just(.resetPage),
                        Observable.just(.setIsLast(data.isLast)),
                        Observable.just(Mutation.setLoading(false))
                    ])
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .loadNextPage:
            let nextPage = currentState.currentPage + 1
            if !currentState.isLoading || currentState.isLast {
                return Observable.empty()
            }
            print("loadNextPage")
            return sendAppliesUsecase.execute(page: nextPage)
                .flatMap { data -> Observable<Mutation> in
                    let posts = data.applys.map { $0.post }
                    return Observable.concat([
                        Observable.just(Mutation.setLoading(true)),
                        Observable.just(.setSendMatePost(list: posts, isAppend: true)),
                        Observable.just(.incrementPage),
                        Observable.just(.setIsLast(data.isLast)),
                        Observable.just(Mutation.setLoading(false))
                    ])
                }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setSendMatePost(let applies, let isAppend):
            if isAppend {
                newState.sendMates.append(contentsOf: applies)
            } else {
                newState.sendMates = applies
            }
        case .incrementPage:
            newState.currentPage += 1
        case .resetPage:
            newState.currentPage = 0
        case .setIsLast(let state):
            newState.isLast = state
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
