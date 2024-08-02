//
//  SignReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 6/12/24.
//

import UIKit
import ReactorKit
import RxSwift

enum SignUpError: Error {
    case apiError
    case ageError
    case dataError
    case loginDataError
}

enum ValidatCase: String {
    case none = ""
    case success = "사용 가능한 닉네임입니다"
    case failed = "이미 사용 중인 닉네임입니다"
}

final class SignReactor: Reactor {
    enum Action {
        case updateNickname(String)
        case endEditNickname
        case updateBirth(String)
        case updateGender(Gender)
        case updateTeam(Team)
        case updateCheerStyle(CheerStyles?)
    }
    
    enum Mutation {
        case setNickname(String)
        case endEditingNickname(Bool?)
        case setCount(Int)
        case setBirth(String)
        case setGender(Gender)
        case setError(Error)
        case setTeam(Team)
        case setCheerStyle(CheerStyles?)
        case validateSignUp
        case validateForm
        case validateTeam
    }
    struct State {
        var nickName: String = ""
        var nickNameValidate: ValidatCase = .none
        var nicknameCount: Int = 0
        var birth: String = ""
        var gender: Gender?
        var team: Team?
        var cheerStyle: CheerStyles?
        var isFormValid: Bool = false
        var signUpModel: SignUpModel?
        var isTeamSelected: Bool = false
        var error: Error?
    }
    
    var initialState: State
    private let nicknameUseCase: NicknameCheckUseCase
    private let loginModel: LoginModel
    private let disposeBag = DisposeBag()
    
    init(loginModel: LoginModel, nicknameUseCase: NicknameCheckUseCase) {
        //usecase 추가하기
        self.initialState = State(
            nickName: loginModel.nickName ?? "",
            birth: loginModel.birth ?? "",
            gender: loginModel.gender
        )
        self.loginModel = loginModel
        self.nicknameUseCase = nicknameUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateNickname(let nickName):
            return Observable.concat([
                Observable.just(Mutation.setNickname(nickName)),
                Observable.just(Mutation.setCount(nickName.count)),
                Observable.just(Mutation.validateForm),
                Observable.just(Mutation.validateSignUp)
            ])
        case .endEditNickname:
            if !currentState.nickName.isEmpty {
                return nicknameUseCase.checkNickname(currentState.nickName)
                    .flatMap { result in
                        return Observable.just(Mutation.endEditingNickname(result))
                    }
            }
            return Observable.just(Mutation.endEditingNickname(nil))
        case .updateBirth(let birth):
            return Observable.concat([
                Observable.just(Mutation.setBirth(birth)),
                Observable.just(Mutation.validateForm),
                Observable.just(Mutation.validateSignUp)
            ])
        case .updateGender(let gender):
            return Observable.concat([
                Observable.just(Mutation.setGender(gender)),
                Observable.just(Mutation.validateForm),
                Observable.just(Mutation.validateSignUp)
            ])
        case .updateTeam(let team):
            return Observable.concat([
                Observable.just(Mutation.setTeam(team)),
                Observable.just(Mutation.validateTeam),
                Observable.just(Mutation.validateSignUp)
            ])
        case .updateCheerStyle(let cheerStyle):
            return Observable.concat([
                Observable.just(Mutation.setCheerStyle(cheerStyle)),
                Observable.just(Mutation.validateSignUp)
            ])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNickname(let nickname):
            newState.nickName = nickname
        case .endEditingNickname(let state):
            if let state = state {
                newState.nickNameValidate = state ? .success : .failed
            } else {
                newState.nickNameValidate = .none
            }
        case .setBirth(let birth):
            newState.birth = birth
        case .setGender(let gender):
            newState.gender = gender
        case .setError(let error):
            newState.error = error
        case .setCount(let count):
            newState.nicknameCount = count
        case .validateForm:
            newState.isFormValid = !newState.nickName.isEmpty && newState.birth.count == 6 && newState.gender != nil && newState.nickNameValidate == .success
        case .setTeam(let team):
            newState.team = team
        case .validateTeam:
            newState.isTeamSelected = !(newState.team == nil)
        case .setCheerStyle(let cheerStyle):
            newState.cheerStyle = cheerStyle
        case .validateSignUp:
            if !newState.nickName.isEmpty, !newState.birth.isEmpty, let gender = newState.gender, let team = newState.team {
                if let birthString = toServerFormatBirth(from: newState.birth) {
                    let model = SignUpModel(accessToken: loginModel.accessToken, refreshToken: loginModel.refreshToken, nickName: newState.nickName, birth: birthString, team: team, gender: gender, cheerStyle: newState.cheerStyle)
                    newState.signUpModel = model
                } 
            }
        }
        return newState
    }
    
    private func toServerFormatBirth(from birth: String) -> String? {
        if let date = DateHelper.shared.toDate(from: birth, format: "yyMMdd") {
            return DateHelper.shared.toString(from: date, format: "yyyy-MM-dd")
        }
        return nil
    }
}

