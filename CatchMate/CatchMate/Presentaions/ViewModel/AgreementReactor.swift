//
//  AgreementReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 3/3/25.
//
import UIKit
import ReactorKit
import RxSwift

final class AgreementReactor: Reactor {
    enum Action {
        // 사용자의 입력과 상호작용하는 역할을 한다
        case requiredAgreementChecked
        case selectAgreement(Int)
    }
    enum Mutation {
        // Action과 State 사이의 다리역할이다.
        // action stream을 변환하여 state에 전달한다.
        case setAgreements([Bool])
    }
    struct State {
        // View의 state를 관리한다.
        var currentAgreements: [Bool] = [Bool](repeating: false, count: 3)
        var isNextEnabled: Bool = false
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requiredAgreementChecked:
            let state = currentState.isNextEnabled
            return Observable.just(.setAgreements([!state, !state, currentState.currentAgreements[2]]))

        case .selectAgreement(let index):
            var newAgreements = currentState.currentAgreements
            newAgreements[index] = !newAgreements[index]
            return Observable.just(.setAgreements(newAgreements))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setAgreements(let newAgreements):
            newState.currentAgreements = newAgreements
            let isAll = newAgreements[0] && newAgreements[1]
            newState.isNextEnabled = isAll
        }
        return newState
    }
}
