//
//  SignReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 6/12/24.
//

import UIKit
import ReactorKit
import RxSwift

final class SignReactor: Reactor {
    enum Action {
        case updateNickname(String)
        case updateBirth(String)
        case updateGender(Gender)
        case updateTeam(Team)
    }
    enum Mutation {
        case setNickname(String)
        case setCount(Int)
        case setBirth(String)
        case setGender(Gender)
        case setError(Error)
        case setTeam(Team)
        case validateForm
        case validateTeam
    }
    struct State {
        var nickName: String = ""
        var nicknameCount: Int = 0
        var birth: String = ""
        var gender: Gender?
        var team: Team?
        var signUpViewNextButtonState: Bool = false
        var isFormValid: Bool = false
        var isTeamSelected: Bool = false
        var error: Error?
    }
    
    var initialState: State
    
    init() {
        //usecase 추가하기
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateNickname(let nickName):
            return Observable.concat([
                Observable.just(Mutation.setNickname(nickName)),
                Observable.just(Mutation.setCount(nickName.count)),
                Observable.just(Mutation.validateForm)
            ])
        case .updateBirth(let birth):
            return Observable.concat([
                Observable.just(Mutation.setBirth(birth)),
                Observable.just(Mutation.validateForm)
            ])
        case .updateGender(let gender):
            return Observable.concat([
                Observable.just(Mutation.setGender(gender)),
                Observable.just(Mutation.validateForm)
            ])
        case .updateTeam(let team):
            return Observable.concat([
                Observable.just(Mutation.setTeam(team)),
                Observable.just(Mutation.validateTeam)
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNickname(let nickname):
            newState.nickName = nickname
        case .setBirth(let birth):
            newState.birth = birth
        case .setGender(let gender):
            newState.gender = gender
        case .setError(let error):
            newState.error = error
        case .setCount(let count):
            newState.nicknameCount = count
        case .validateForm:
            newState.isFormValid = !newState.nickName.isEmpty && newState.birth.count == 6 && newState.gender != nil
        case .setTeam(let team):
            newState.team = team
        case .validateTeam:
            newState.isTeamSelected = !(newState.team == nil)
        }
        return newState
    }
}
