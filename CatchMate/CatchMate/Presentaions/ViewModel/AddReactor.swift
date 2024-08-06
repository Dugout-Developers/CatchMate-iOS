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
        case updatePost
    }
    enum Mutation {
        // Action과 State 사이의 다리역할이다.
        // action stream을 변환하여 state에 전달한다.
        case updateTitle(String)
        case updateDate(Date?)
        case updateTime(PlayTime)
        case updateGender(Gender?)
        case updateAge([Int])
        case updateDatePickerSaveButton
        case updateHomeTeam(Team)
        case updageAwayTeam(Team)
        case updateAddText(String)
        case updatePartyNumber(Int)
        case updateSaveButton
        case updatePlcase(String)
        case updatePost
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
        var addText: String = ""
        var partyNumber: Int?
        var saveButtonState: Bool = false
    }
    
    var initialState: State
    private let addUsecase: AddPostUseCase
    init(addUsecase: AddPostUseCase) {
        self.initialState = State()
        self.addUsecase = addUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
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
                Observable.just(Mutation.updateSaveButton)
            ])
        case .changeAwayTeam(let team):
            return Observable.concat([
                Observable.just(Mutation.updageAwayTeam(team)),
                Observable.just(Mutation.updateSaveButton)
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
            return Observable.just(Mutation.updatePost)
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
        case .updatePost:
            // TODO: - UseCase upload 시스템 서버 연결
            break
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
        }
        return newState
    }

}
