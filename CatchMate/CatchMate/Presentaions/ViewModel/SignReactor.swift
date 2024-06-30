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

final class SignReactor: Reactor {
    enum Action {
        case kakaoLogin
        case appleLogin
        case naverLogin
        case updateNickname(String)
        case updateBirth(String)
        case updateGender(Gender)
        case updateTeam(Team)
        case updateCheerStyle(CheerStyles?)
        case signUpUser
    }
    enum Mutation {
        case getSNSLoginInfo(LoginModel)
        case setNickname(String)
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
        var loginModel: LoginModel?
        var nickName: String = ""
        var nicknameCount: Int = 0
        var birth: String = ""
        var gender: Gender?
        var team: Team?
        var cheerStyle: CheerStyles?
        var user: User?
        var signUpViewNextButtonState: Bool = false
        var isFormValid: Bool = false
        var isSignUp: Bool?
        var isTeamSelected: Bool = false
        var error: Error?
    }
    
    var initialState: State
    private let kakaoLoginUseCase: KakaoLoginUseCase
    private let appleLoginUseCase: AppleLoginUseCase
    private let naverLoginUseCase: NaverLoginUseCase
    
    init(kakaoUsecase: KakaoLoginUseCase, appleUsecase: AppleLoginUseCase, naverUsecase: NaverLoginUseCase) {
        //usecase 추가하기
        self.initialState = State()
        self.kakaoLoginUseCase = kakaoUsecase
        self.appleLoginUseCase = appleUsecase
        self.naverLoginUseCase = naverUsecase
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
        case .updateCheerStyle(let cheerStyle):
            return Observable.just(Mutation.setCheerStyle(cheerStyle))
        case .signUpUser:
            return Observable.just(Mutation.validateSignUp)
        case .kakaoLogin:
            return kakaoLoginUseCase.login()
                .map { Mutation.getSNSLoginInfo($0) }
                .catch { error in
                    Observable.just(Mutation.setError(error))
                }
        case .appleLogin:
            return appleLoginUseCase.login()
                .map { Mutation.getSNSLoginInfo($0) }
                .catch { error in
                    Observable.just(Mutation.setError(error))
                }
        case .naverLogin:
            return naverLoginUseCase.login()
                .map { Mutation.getSNSLoginInfo($0) }
                .catch { error in
                    Observable.just(Mutation.setError(error))
                }
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
        case .setCheerStyle(let cheerStyle):
            newState.cheerStyle = cheerStyle
        case .validateSignUp:
            if !newState.nickName.isEmpty, !newState.birth.isEmpty, let gender = newState.gender, let team = newState.team, let snsId = newState.loginModel?.id, let email = newState.loginModel?.email {
                if let age = birthToAge(newState.birth) {
                    newState.user = User(snsID: snsId, email: email, nickName: newState.nickName, age: age, team: team, gener: gender, cheerStyle: newState.cheerStyle, profilePicture: nil)
                    newState.isSignUp = true
                    print(newState.user ?? "Error")
                } else {
                    newState.isSignUp = false
                    newState.error = SignUpError.ageError
                }
            } else {
                newState.isSignUp = false
                newState.error = SignUpError.dataError
            }
        case .getSNSLoginInfo(let loginInfo):
            newState.loginModel = loginInfo
            if let gender = newState.loginModel?.gender {
                newState.gender = gender
            }
            if let nickname = newState.loginModel?.nickName {
                newState.nickName = nickname
            }
            if let birth = newState.loginModel?.birth {
                newState.birth = birth
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
}
