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
        case signUpUser
    }
    enum Mutation {
        case setNickname(String)
        case setValidateCase
        case setIsEditingNickName(Bool)
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
        var isEditingNickname: Bool = false
        var nicknameCount: Int = 0
        var birth: String = ""
        var gender: Gender?
        var team: Team?
        var cheerStyle: CheerStyles?
        var signUpViewNextButtonState: Bool = false
        var isFormValid: Bool = false
        var isSignUp: Bool?
        var signupResponse: SignUpResponse? = nil
        var isTeamSelected: Bool = false
        var error: Error?
    }
    
    var initialState: State
    private let signupUseCase: SignUpUseCase
    private let loginModel: LoginModel
    private let disposeBag = DisposeBag()

    init(loginModel: LoginModel, signupUseCase: SignUpUseCase) {
        //usecase 추가하기
        self.initialState = State()
        self.loginModel = loginModel
        self.signupUseCase = signupUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateNickname(let nickName):
            return Observable.concat([
                Observable.just(Mutation.setIsEditingNickName(true)),
                Observable.just(Mutation.setValidateCase),
                Observable.just(Mutation.setNickname(nickName)),
                Observable.just(Mutation.setCount(nickName.count)),
                Observable.just(Mutation.validateForm)
            ])
        case .endEditNickname:
            return Observable.concat([
                Observable.just(Mutation.setIsEditingNickName(false)),
                Observable.just(Mutation.setValidateCase)
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
        case .updateCheerStyle(let cheerStyle):
            return Observable.just(Mutation.setCheerStyle(cheerStyle))
        case .signUpUser:
            return Observable.just(Mutation.validateSignUp)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNickname(let nickname):
            newState.nickName = nickname
        case .setValidateCase:
            // TODO: - 서버 Validate 통신 결과에 맞춰 상태 바꾸기 (임시결과로 대체)
            if newState.isEditingNickname {
                // 닉네임 작성중일때
                if newState.nicknameCount == 0 { newState.nickNameValidate = .none }
                else if newState.nicknameCount < 4 {  newState.nickNameValidate = .failed }
                else {  newState.nickNameValidate = .success }
            } else {
                // 작성이 끝났을 때 -> 중복이면 failed 중복이 아니면 none
                if newState.nicknameCount >= 4 { newState.nickNameValidate = .none }
            }
        case .setIsEditingNickName(let isEditing):
            newState.isEditingNickname = isEditing
        case .setBirth(let birth):
            newState.birth = birth
        case .setGender(let gender):
            newState.gender = gender
        case .setError(let error):
            newState.error = error
        case .setCount(let count):
            newState.nicknameCount = count
        case .validateForm:
            newState.isFormValid = !newState.nickName.isEmpty && newState.birth.count == 6 && newState.gender != nil && newState.nickNameValidate == .none
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
                    signupUseCase.signup(model)
                        .subscribe(onNext: { result in
                              switch result {
                              case .success(let response):
                                  print("Sign up successful: \(response)")
                                  newState.signupResponse = response
                                  newState.isSignUp = true
                              case .failure(let error):
                                  print("Sign up failed with error: \(error)")
                                  newState.isSignUp = false
                                  newState.error = error
                              }
                          }, onError: { error in
                              print("Unexpected error: \(error)")
                              newState.isSignUp = false
                              newState.error = error
                          })
                          .disposed(by: disposeBag)
                } else {
                    newState.isSignUp = false
                    newState.error = SignUpError.ageError
                }
            } else {
                newState.isSignUp = false
                newState.error = SignUpError.dataError
            }
        }
        return newState
    }
    
    private func birthToAge(_ birth: String) -> UInt? {
        guard birth.count == 6 else { return nil }
        
        let yearString = String(birth.prefix(2))
        let monthString = String(birth.dropFirst(2).prefix(2))
        let dayString = String(birth.dropFirst(4))
        
        guard let year = Int(yearString), let month = Int(monthString), let day = Int(dayString) else { return nil }
        
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentCentury = currentYear / 100
        let birthYear = (year <= currentYear % 100) ? (currentCentury * 100 + year) : ((currentCentury - 1) * 100 + year)
        
        var birthDateComponents = DateComponents()
        birthDateComponents.year = birthYear
        birthDateComponents.month = month
        birthDateComponents.day = day
        
        let calendar = Calendar.current
        guard let birthDate = calendar.date(from: birthDateComponents) else { return nil }
        
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        if let age = ageComponents.year, age >= 0 {
            return UInt(age)
        } else {
            return nil
        }
    }
    
    private func toServerFormatBirth(from birth: String) -> String? {
        if let date = DateHelper.shared.toDate(from: birth, format: "yyMMdd") {
            return DateHelper.shared.toString(from: date, format: "yyyy-MM-dd")
        }
        return nil
    }
}
