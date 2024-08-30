//
//  AddReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 7/12/24.
//

import UIKit
import RxSwift
import ReactorKit

enum PlayTime: String, CaseIterable {
    case two = "14:00"
    case five = "17:00"
    case six = "18:00"
    case sixMiddle = "18:30"
}
final class AddReactor: Reactor {
    enum Action {
        case loadUser
        case changeTitle(String)
        case changeDate(Date?)
        case changeTime(PlayTime)
        case changeGender(Gender?)
        case changeAge([Int])
        case changeHomeTeam(Team)
        case changeAwayTeam(Team)
        case changeAddText(String)
        case changePartyNumber(Int)
        case changePlcase(String)
        case changeCheerTeam(Team)
        case updatePost
    }
    enum Mutation {
        // Action과 State 사이의 다리역할이다.
        // action stream을 변환하여 state에 전달한다.
        case setUser(SimpleUser)
        case updateTitle(String)
        case updateDate(Date?)
        case updateTime(PlayTime)
        case updateGender(Gender?)
        case updateAge([Int])
        case updateDatePickerSaveButton
        case updateHomeTeam(Team)
        case updageAwayTeam(Team)
        case updateCheerTeam(Team)
        case updateCheerTeamPickerState
        case updateAddText(String)
        case updatePartyNumber(Int)
        case updateSaveButton
        case updatePlcase(String)
        case updatePost(Post)
        case setError(PresentationError)
    }
    struct State {
        // View의 state를 관리한다.
        var title: String = ""
        var selecteDate: Date?
        var selecteTime: PlayTime?
        var dateInfoString: String = ""
        var selectedGender: Gender?
        var selectedAge: [Int] = []
        var datePickerSaveButtonState: Bool = false
        var homeTeam: Team?
        var place: String? = ""
        var awayTeam: Team?
        var isDisableCheerTeamPicker: Bool = true
        var cheerTeam: Team?
        var addText: String = ""
        var partyNumber: Int?
        var saveButtonState: Bool = false
        var loadSavePost: Post? = nil
        var error: PresentationError?
    }
    
    var initialState: State
    var writer: SimpleUser?
    private let addUsecase: AddPostUseCase
    private let loadPostDetailUsecase: LoadPostUseCase
    private let loadUserUsecase: UserUseCase
    init(addUsecase: AddPostUseCase, loadPostDetailUsecase: LoadPostUseCase, loadUserUsecase: UserUseCase) {
        self.initialState = State()
        self.addUsecase = addUsecase
        self.writer = nil
        self.loadPostDetailUsecase = loadPostDetailUsecase
        self.loadUserUsecase = loadUserUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadUser:
            return loadUserUsecase.loadUser()
                .map { user in
                    let simpleUser = SimpleUser(user: user)
                    return Mutation.setUser(simpleUser)
                }
                .catch { error in
                    if let presentationError = error as? PresentationError {
                        return Observable.just(Mutation.setError(presentationError))
                    } else {
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }

        case .changeGender(let gender):
            return Observable.concat([
                Observable.just(Mutation.updateGender(gender)),
                Observable.just(Mutation.updateSaveButton)
            ])
        case .changeAge(let ages):
            return Observable.concat([
                Observable.just(Mutation.updateAge(ages)),
                Observable.just(Mutation.updateSaveButton)
            ])
        case .changeDate(let date):
            return Observable.concat([
                Observable.just(Mutation.updateDate(date)),
                Observable.just(Mutation.updateDatePickerSaveButton),
                Observable.just(Mutation.updateSaveButton)
            ])
        case .changeTime(let palyTime):
            return Observable.concat([
                Observable.just(Mutation.updateTime(palyTime)),
                Observable.just(Mutation.updateDatePickerSaveButton),
                Observable.just(Mutation.updateSaveButton)
            ])
        case .changeHomeTeam(let team):
            return Observable.concat([
                Observable.just(Mutation.updateHomeTeam(team)),
                Observable.just(Mutation.updateSaveButton),
                Observable.just(Mutation.updateCheerTeamPickerState)
            ])
        case .changeAwayTeam(let team):
            return Observable.concat([
                Observable.just(Mutation.updageAwayTeam(team)),
                Observable.just(Mutation.updateSaveButton),
                Observable.just(Mutation.updateCheerTeamPickerState)
            ])
        case .changeAddText(let text):
            return Observable.concat([
                Observable.just(Mutation.updateAddText(text)),
                Observable.just(Mutation.updateSaveButton)
            ])
        case .changePartyNumber(let num):
            return Observable.concat([
                Observable.just(Mutation.updatePartyNumber(num)),
                Observable.just(Mutation.updateSaveButton)
            ])
        case .updatePost:
            guard let request = validatePost(currentState) else {
                print(currentState)
                return Observable.just(Mutation.setError(.validationFailed(message: "입력값 확인 후 다시 시도해주세요.")))
            }
            print(request.0)
            return addUsecase.addPost(request.0)
                .map{ _ in 
                    let post = Post(post: request.0, writer: request.1)
                    return Mutation.updatePost(post)
                }
                .catch { error in
                    if let presentationError = error as? PresentationError {
                        return Observable.just(Mutation.setError(presentationError))
                    } else {
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
        case .changeTitle(let title):
            return Observable.concat([
                Observable.just(Mutation.updateTitle(title)),
                Observable.just(Mutation.updateSaveButton)
            ])
        case .changePlcase(let place):
            return Observable.concat([
                Observable.just(Mutation.updatePlcase(place)),
                Observable.just(Mutation.updateSaveButton)
            ])
        case .changeCheerTeam(let team):
            return Observable.concat([
                Observable.just(Mutation.updateCheerTeam(team)),
                Observable.just(Mutation.updateSaveButton)
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .updateGender(let gender):
            newState.selectedGender = gender
        case .updateAge(let ages):
            newState.selectedAge = ages
        case .updateDate(let date):
            newState.selecteDate = date
        case .updateTime(let time):
            newState.selecteTime = time
        case .updateDatePickerSaveButton:
            if let date = newState.selecteDate, let time = newState.selecteTime {
                newState.dateInfoString = "\(DateHelper.shared.toString(from: date, format: "M월d일 EEEE")) | \(time.rawValue)"
                newState.datePickerSaveButtonState = true
            } else {
                newState.datePickerSaveButtonState = false
            }
        case .updateHomeTeam(let team):
            newState.homeTeam = team
            newState.place = team.place?[0] ?? ""
        case .updageAwayTeam(let team):
            newState.awayTeam = team
        case .updateAddText(let text):
            newState.addText = text
        case .updatePartyNumber(let num):
            newState.partyNumber = num
        case .updatePost(let post):
            newState.loadSavePost = post
            
        case .updateSaveButton:
            if newState.selecteDate != nil , newState.selecteTime != nil , newState.homeTeam != nil, newState.awayTeam != nil, newState.place != nil, newState.addText.trimmingCharacters(in: .whitespaces).isEmpty, newState.title.trimmingCharacters(in: .whitespaces).isEmpty {
                newState.saveButtonState = true
            } else {
                newState.saveButtonState = false
            }
        case .updateTitle(let title):
            newState.title = title
        case .updatePlcase(let place):
            newState.place = place
        case .setError(let error):
            newState.error = error
        case .setUser(let user):
            writer = user
        case .updateCheerTeam(let team):
            newState.cheerTeam = team
        case .updateCheerTeamPickerState:
            if let home = currentState.homeTeam, let away = currentState.awayTeam {
                newState.isDisableCheerTeamPicker = false
                if let myTeamStr = SetupInfoService.shared.getUserInfo(type: .team), let myTeam = Team(rawValue: myTeamStr) {
                    if home == myTeam || away == myTeam {
                        newState.cheerTeam = myTeam
                    } else {
                        newState.cheerTeam = nil
                    }
                }
            } else {
                newState.isDisableCheerTeamPicker = true
            }
        }
        return newState
    }
    private func validatePost(_ state: State) -> (RequestPost, SimpleUser)? {
        if let user = writer, let homeTeam = state.homeTeam, let awayTeam = state.awayTeam, let cheerTeam = state.cheerTeam, let place = state.place, let maxNum = state.partyNumber, let date = state.selecteDate, let time = state.selecteTime,
           !place.isEmpty, !state.title.isEmpty {
            let request = RequestPost(title: state.title, homeTeam: homeTeam, awayTeam: awayTeam, cheerTeam: cheerTeam, date: date, playTime: time.rawValue, location: place, maxPerson: maxNum, preferGender: state.selectedGender, preferAge: state.selectedAge, addInfo: state.addText)
            return (request, user)
        }
        return nil
    }
}
