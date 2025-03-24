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
        case setError(PresentationError?)
    }
    struct State {
        var text: String?
        var count: Int = 0
        var isSubmit: Bool = false
        var error: PresentationError?
    }
    var initialState: State
    
    private let menu: CustomerServiceMenu
    private let inquiriesUsecase: InquiriesUseCase
    init(menu: CustomerServiceMenu, inquiriesUsecase: InquiriesUseCase) {
        self.initialState = State()
        self.menu = menu
        self.inquiriesUsecase = inquiriesUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changeText(let text):
            return Observable.concat([
                Observable.just(.setText(text)),
                Observable.just(.setCount(text?.count ?? 0))
            ])
        case .submitContent:
            guard let text = currentState.text else {
                return Observable.empty()
            }
            return inquiriesUsecase.inquiry(type: self.menu, content: text)
                .map { _ in
                    return Mutation.setIsSubmit(true)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
                
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.error = nil
        switch mutation {
        case .setText(let text):
            newState.text = text
        case .setCount(let count):
            newState.count = count
        case .setIsSubmit(let state):
            newState.isSubmit = state
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
