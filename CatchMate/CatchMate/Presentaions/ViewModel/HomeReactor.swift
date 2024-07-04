//
//  HomeReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import RxSwift
import ReactorKit

final class HomeReactor: Reactor {
    enum Action {
//        case willAppear
        case updateDateFilter(Date?)
        case updateTeamFilter([Team])
    }
    enum Mutation {
        // Action과 State 사이의 다리역할이다.
        // action stream을 변환하여 state에 전달한다.
//        case loadPost
        case setDateFilter(Date?)
        case setTeamFilter([Team])
    }
    struct State {
        // View의 state를 관리한다.
        var dateFilterValue: Date?
        var teamFilterValue: [Team] = []
        var error: Error?
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateDateFilter(let date):
            return Observable.just(Mutation.setDateFilter(date))

        case .updateTeamFilter(let team):
            return Observable.just(Mutation.setTeamFilter(team))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setDateFilter(let date):
            newState.dateFilterValue = date
        case .setTeamFilter(let team):
            newState.teamFilterValue = team
        }
        return newState
    }
}
