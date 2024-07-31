//
//  SignUpReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 7/31/24.
//

import RxSwift
import ReactorKit

final class SignUpReactor: Reactor {
    enum Action {
        case signUpUser
    }
    enum Mutation {
        case requestSignUp
        
    }
    struct State {
        // View의 state를 관리한다.
        var signupResponse: SignUpResponse? = nil
        var error: Error?
    }
    
    var initialState: State
    private let signupUseCase: SignUpUseCase
    private let signUpModel: SignUpModel
    private let disposeBag = DisposeBag()
    init(signUpModel: SignUpModel, signupUseCase: SignUpUseCase) {
        self.initialState = State()
        self.signUpModel = signUpModel
        self.signupUseCase = signupUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .signUpUser:
            return Observable.just(Mutation.requestSignUp)
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .requestSignUp:
            signupUseCase.signup(signUpModel)
                .subscribe(onNext: { result in
                    switch result {
                    case .success(let response):
                        print("Sign up successful: \(response)")
                        newState.signupResponse = response
                    case .failure(let error):
                        print("Sign up failed with error: \(error)")
                        newState.error = error
                        newState.error = nil
                    }
                })
                .disposed(by: disposeBag)
        }
        return newState
    }
}
