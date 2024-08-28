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
        case setError(PresentationError?)
    }
    struct State {
        // View의 state를 관리한다.
        var signupResponse: SignUpResponse? = nil
        var error: PresentationError?
    }
    
    var initialState: State
    private let signupUseCase: SignUpUseCase
    private let signUpModel: SignUpModel
    private let loginModel: LoginModel
    private let disposeBag = DisposeBag()
    init(signUpModel: SignUpModel, loginModel: LoginModel, signupUseCase: SignUpUseCase) {
        self.initialState = State()
        self.signUpModel = signUpModel
        self.loginModel = loginModel
        self.signupUseCase = signupUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .signUpUser:
            return signupUseCase.signup(loginModel, signupInfo: signUpModel)
                .withUnretained(self)
                .map { reactor, response in
                    reactor.saveToken(accessToken: response.accessToken, refreshToken: response.refreshToken)
                    return Mutation.setSignUpResponse(response)
                }
                .catch { error in
                    if let presentaionError = error as? PresentationError {
                        return Observable.just(.setError(presentaionError))
                    } else {
                        return Observable.just(.setError(.unknown(message: error.localizedDescription)))
                    }
                }
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
    
    private func saveToken(accessToken: String, refreshToken: String) {
        LoggerService.shared.debugLog("saveKeychain : \(loginModel.accessToken), \(loginModel.refreshToken)")
        KeychainService.saveToken(token: accessToken, for: .accessToken)
        KeychainService.saveToken(token: refreshToken, for: .refreshToken)
    }
}
