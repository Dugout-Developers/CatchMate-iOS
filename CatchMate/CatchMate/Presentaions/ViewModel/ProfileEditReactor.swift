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
        case changeTeam(Team)
        case changeCheerStyle(CheerStyles?)
    }
    enum Mutation {
        case setNickName(String)
        case setNickNameCount(Int)
        case setTeam(Team)
        case setCheerStyle(CheerStyles?)
    }
    struct State {
        var nickname: String
        var nickNameCount: Int
        var team: Team
        var cheerStyle: CheerStyles?
    }
    
    var initialState: State
    private var currentUserInfo: User
    init(user: User) {
        self.currentUserInfo = user
        self.initialState = State(nickname: user.nickName, nickNameCount: user.nickName.count, team: user.team, cheerStyle: user.cheerStyle)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changeNickname(let nickname):
            return Observable.concat([
                Observable.just(Mutation.setNickName(nickname)),
                Observable.just(Mutation.setNickNameCount(nickname.count))
            ])
        case .changeTeam(let team):
            return Observable.just(Mutation.setTeam(team))
        case .changeCheerStyle(let style):
            return Observable.just(Mutation.setCheerStyle(style))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNickName(let nickname):
            newState.nickname = nickname
        case .setNickNameCount(let count):
            newState.nickNameCount = count
        case .setTeam(let team):
            newState.team = team
        case .setCheerStyle(let style):
            newState.cheerStyle = style
        }
        return newState
    }
}
