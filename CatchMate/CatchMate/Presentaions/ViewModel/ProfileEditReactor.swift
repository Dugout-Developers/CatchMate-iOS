//
//  ProfileEditReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

import UIKit
import RxSwift
import ReactorKit

final class ProfileEditReactor: Reactor {
    enum Action {
        case changeNickname(String)
    }
    enum Mutation {
        case setNickName(String)
        case setNickNameCount(Int)
    }
    struct State {
        var nickname: String
        var nickNameCount: Int
    }
    
    var initialState: State
    private var currentUserInfo: User
    init(user: User) {
        self.currentUserInfo = user
        self.initialState = State(nickname: user.nickName, nickNameCount: user.nickName.count)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changeNickname(let nickname):
            return Observable.concat([
                Observable.just(Mutation.setNickName(nickname)),
                Observable.just(Mutation.setNickNameCount(nickname.count))
            ])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNickName(let nickname):
            newState.nickname = nickname
        case .setNickNameCount(let count):
            newState.nickNameCount = count
        }
        return newState
    }
}
