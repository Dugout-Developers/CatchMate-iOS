//
//  CustomerServiceReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 2/11/25.
//

import UIKit
import ReactorKit
import RxSwift

final class CustomerServiceReactor: Reactor {
    enum Action {
        // 사용자의 입력과 상호작용하는 역할을 한다
        case changeText(String?)
        case submitContent
    }
    enum Mutation {
        case setText(String?)
        case setCount(Int)
        case setIsSubmit(Bool)
    }
    struct State {
        var text: String?
        var count: Int = 0
        var isSubmit: Bool = false
    }
    var initialState: State
    
    private let menu: CustomerServiceMenu
    init(menu: CustomerServiceMenu) {
        self.initialState = State()
        self.menu = menu
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changeText(let text):
            return Observable.concat([
                Observable.just(.setText(text)),
                Observable.just(.setCount(text?.count ?? 0))
            ])
        case .submitContent:
            return Observable.just(.setIsSubmit(true))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setText(let text):
            newState.text = text
        case .setCount(let count):
            newState.count = count
        case .setIsSubmit(let state):
            newState.isSubmit = state
        }
        return newState
    }
}
