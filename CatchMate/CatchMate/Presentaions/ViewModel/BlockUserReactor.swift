//
//  BlockUserReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 10/8/24.
//

import UIKit
import RxSwift
import ReactorKit

final class BlockUserReactor: Reactor {
    enum Action {
        case loadBlockUser
        case unblockUser(String)
    }
    enum Mutation {
        case setBlockUser([SimpleUser])
    }
    struct State {
        // View의 state를 관리한다.
        var blockUsers: [SimpleUser] = []
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadBlockUser:
            return Observable.just(Mutation.setBlockUser(SimpleUser.blockUsers))
        case .unblockUser(let userId):
            var users = SimpleUser.blockUsers
            if let index = SimpleUser.blockUsers.firstIndex(where: { $0.userId == userId }) {
                users.remove(at: index)
            }
            SimpleUser.blockUsers = users
            return Observable.just(Mutation.setBlockUser(SimpleUser.blockUsers))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setBlockUser(let users):
            newState.blockUsers = users
        }
        return newState
    }
}
