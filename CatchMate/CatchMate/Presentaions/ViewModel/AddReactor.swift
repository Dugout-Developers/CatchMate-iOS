//
//  AddReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 7/12/24.
//

import UIKit
import RxSwift
import ReactorKit

final class AddReactor: Reactor {
    enum Action {
        // 사용자의 입력과 상호작용하는 역할을 한다
        case changeGender(Gender?)
        case changeAge([Int])
    }
    enum Mutation {
        // Action과 State 사이의 다리역할이다.
        // action stream을 변환하여 state에 전달한다.
        case updateGender(Gender?)
        case updateAge([Int])
    }
    struct State {
        // View의 state를 관리한다.
        var selectedGender: Gender?
        var selectedAge: [Int] = []
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changeGender(let gender):
            return Observable.just(Mutation.updateGender(gender))
        case .changeAge(let ages):
            return Observable.just(Mutation.updateAge(ages))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .updateGender(let gender):
            newState.selectedGender = gender
            print(newState.selectedGender)
        case .updateAge(let ages):
            newState.selectedAge = ages
            print(newState.selectedAge)
        }
        return newState
    }

}
