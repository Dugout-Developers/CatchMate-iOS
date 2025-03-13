//
//  TabbarReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 3/13/25.
//
import RxSwift
import ReactorKit
import Foundation

final class TabbarReactor: Reactor {
    enum Action {
        case loadHasUnread
        
    }
    enum Mutation {
        case setHasUnread((notification: Bool, chat: Bool))
    }
    struct State {
        var hasUnreadNotification: Bool = false
        var hasUnreadChat: Bool = false
    }
    
    var initialState: State
    private let unreaMessageUC: UnreadMessageUseCase
    private let disposeBag: DisposeBag = DisposeBag()
    init(unreaMessageUC: UnreadMessageUseCase) {
        self.initialState = State()
        self.unreaMessageUC = unreaMessageUC
        NotificationCenter.default.rx.notification(.reloadUnreadMessageState)
            .map { _ in TabbarReactor.Action.loadHasUnread }
            .bind(to: action)
            .disposed(by: disposeBag)
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadHasUnread:
            print("Unread Message Load")
            return unreaMessageUC.unreadMessageState()
                .map { Mutation.setHasUnread($0) }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            
        case .setHasUnread((let notification, let chat)):
            newState.hasUnreadChat = chat
            newState.hasUnreadNotification = notification
        }
        return newState
    }
}
