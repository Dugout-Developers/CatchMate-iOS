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
        case setSignUpResponse(SignUpResponse)
        case setError(Error?)
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
            return signupUseCase.signup(signUpModel)
                .map { result in
                    switch result {
                    case .success(let response):
                        return .setSignUpResponse(response)
                    case .failure(let error):
                        return .setError(error)
                    }
                }
                .catchAndReturn(.setError(nil)) // 에러 발생 시
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setSignUpResponse(response):
            LoggerService.shared.log("SignReactor: - SignUp success \(response)")
            newState.signupResponse = response
            newState.error = nil
        case let .setError(error):
            newState.signupResponse = nil
            newState.error = error
        }
        return newState
    }
}
