//
//  NotificationListReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 1/7/25.
//

import UIKit
import RxSwift
import ReactorKit

final class NotificationListReactor: Reactor {
    enum Action {
        case loadList
    }
    enum Mutation {
        case setList([NotificationList])
        case setError(PresentationError?)
    }
    struct State {
        var notifications: [NotificationList] = []
        var error: PresentationError?
    }
    
    var initialState: State
    private let loadNotiUsecase: LoadNotificationListUseCase
    init(loadlistUsecase: LoadNotificationListUseCase) {
        self.initialState = State()
        self.loadNotiUsecase = loadlistUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadList:
            return loadNotiUsecase.execute()
                .map {
                    Mutation.setList($0)
                }
                .catch { return Observable.just(Mutation.setError($0.toPresentationError()))
                }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.error = nil
        switch mutation {
        case .setList(let list):
            newState.notifications = list
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
