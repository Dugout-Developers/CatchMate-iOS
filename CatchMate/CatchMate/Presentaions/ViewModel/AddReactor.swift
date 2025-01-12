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
        case setupEditPost(post: Post)
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
        case updateEditPost
        case tempPost
        case loadTempPost
        case setTempPost
        case setIsLoadTempPost
    }
    enum Mutation {
        case setUser(SimpleUser)
        case setEditPost(Post?)
        case updateTitle(String)
        case updateDate(Date?)
        case updateTime(PlayTime?)
        case updateGender(Gender?)
        case updateAge([Int])
        case updateDatePickerSaveButton
        case updateHomeTeam(Team?)
        case updageAwayTeam(Team?)
        case updateCheerTeam(Team?)
        case updateCheerTeamPickerState
        case updateAddText(String)
        case updatePartyNumber(Int?)
        case updateSaveButton
        case updatePlcase(String)
        case savePost(Int)
        case editPost(Int)
        case setError(PresentationError)
        case setTempPostResult(Void)
        case setTempPostId(String)
        case setIsLoadTempPost
        case setTempPost(TempPost)
    }
    struct State {
        // View의 state를 관리한다.
        var editPost: Post?
        var tempPostId: String?
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
        var savePostResult: Int? = nil
        var tempPostResult: Void?
        var loadTempPost: Void?
        var isLoadTempPost: Bool = false
        var tempPost: TempPost?
        var error: PresentationError?
    }
    
    var initialState: State
    var writer: SimpleUser?
    private let addUsecase: AddPostUseCase
    private let loadPostDetailUsecase: PostDetailUseCase
    private let loadUserUsecase: LoadMyInfoUseCase
    private let tempPostUsecase: TempPostUseCase
    
    init(addUsecase: AddPostUseCase, loadPostDetailUsecase: PostDetailUseCase, loadUserUsecase: LoadMyInfoUseCase, tempPostUsecase: TempPostUseCase) {
        self.initialState = State()
        self.addUsecase = addUsecase
        self.writer = nil
        self.loadPostDetailUsecase = loadPostDetailUsecase
        self.loadUserUsecase = loadUserUsecase
        self.tempPostUsecase = tempPostUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadUser:
            return loadUserUsecase.execute()
                .map { user in
                    let simpleUser = SimpleUser(user: user)
                    return Mutation.setUser(simpleUser)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(error.toPresentationError()))
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
                return Observable.just(Mutation.setError(.showToastMessage(message: "입력값 확인 후 다시 시도해주세요.")))
            }
            if currentState.isLoadTempPost {
                guard let id = currentState.tempPostId else {
                    return Observable.just(.setError(.showToastMessage(message: "게시물을 등록하는데 문제가 발생했습니다.")))
                }
                return addUsecase.addTempPost(post: request.0, boardId: id)
                    .map{ id in
                        return Mutation.savePost(id)
                    }
                    .catch { error in
                        return Observable.just(Mutation.setError(error.toPresentationError()))
                    }
            } else {
                return addUsecase.addPost(request.0)
                    .map{ id in
                        return Mutation.savePost(id)
                    }
                    .catch { error in
                        return Observable.just(Mutation.setError(error.toPresentationError()))
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
        case .setupEditPost(let post):
            if let playTime = PlayTime(rawValue: post.playTime) {
                return Observable.concat([
                    Observable.just(Mutation.updateTitle(post.title)),
                    Observable.just(Mutation.updatePartyNumber(post.maxPerson)),
                    Observable.just(Mutation.updateDate(DateHelper.shared.toDate(from: post.date, format: "MM.dd"))),
                    Observable.just(Mutation.updateTime(playTime)),
                    Observable.just(Mutation.updateHomeTeam(post.homeTeam)),
                    Observable.just(Mutation.updageAwayTeam(post.awayTeam)),
                    Observable.just(Mutation.updateCheerTeam(post.cheerTeam)),
                    Observable.just(Mutation.updatePlcase(post.location)),
                    Observable.just(Mutation.updateAddText(post.addInfo)),
                    Observable.just(Mutation.updateAge(post.preferAge)),
                    Observable.just(Mutation.updateGender(post.preferGender)),
                    Observable.just(Mutation.setEditPost(post)),
                    Observable.just(Mutation.updateSaveButton)
                ])
            } else {
                return Observable.just(Mutation.setError(PresentationError.showErrorPage))
            }
        case .updateEditPost:
            guard let idStr = currentState.editPost?.id, let id = Int(idStr) else {
                return Observable.just(Mutation.setError(PresentationError.showToastMessage(message: "게시물 수정에 실패했습니다.")))
            }
            guard let request = validatePost(currentState) else {
                return Observable.just(Mutation.setError(.showToastMessage(message: "입력값 확인 후 다시 시도해주세요.")))
            }
            guard let requestEditPost = mappingRequestEditPost(request.0) else {
                return Observable.just(Mutation.setError(.showToastMessage(message: "다시 시도해주세요.")))
            }
            return addUsecase.editPost(requestEditPost, boardId: id)
                .map{ id in
                    return Mutation.editPost(id)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(error.toPresentationError()))
                }
        case .tempPost:
            let tempPost = TempPostRequest(title: currentState.title, homeTeam: currentState.homeTeam, awayTeam: currentState.awayTeam, cheerTeam: currentState.cheerTeam, date: currentState.selecteDate, playTime: currentState.selecteTime?.rawValue, location: currentState.place, maxPerson: currentState.partyNumber, preferGender: currentState.selectedGender, preferAge: currentState.selectedAge, addInfo: currentState.addText)
            return tempPostUsecase.execute(tempPost)
                .map { _ in
                    return Mutation.setTempPostResult(())
                }
                .catch { error in
                    return Observable.just(Mutation.setError(error.toPresentationError()))
                }
            
        case .setTempPost:
            if let post = currentState.tempPost {
                return Observable.concat([
                    Observable.just(Mutation.updateTitle(post.title)),
                    Observable.just(Mutation.updatePartyNumber(post.maxPerson)),
                    Observable.just(Mutation.updateDate(post.date)),
                    Observable.just(Mutation.updateTime(post.playTime)),
                    Observable.just(Mutation.updateHomeTeam(post.homeTeam)),
                    Observable.just(Mutation.updageAwayTeam(post.awayTeam)),
                    Observable.just(Mutation.updateCheerTeam(post.cheerTeam)),
                    Observable.just(Mutation.updatePlcase(post.location)),
                    Observable.just(Mutation.updateAddText(post.addInfo)),
                    Observable.just(Mutation.updateAge(post.preferAge)),
                    Observable.just(Mutation.updateGender(post.preferGender)),
                    Observable.just(Mutation.updateSaveButton),
                    Observable.just(Mutation.updateDatePickerSaveButton),
                    Observable.just(Mutation.setTempPostId(post.id)),
                    Observable.just(Mutation.setIsLoadTempPost)
                ])
            } else {
                return Observable.empty()
            }
        case .loadTempPost:
            return tempPostUsecase.loadTempPost()
                .flatMap { post -> Observable<Mutation> in
                    if let post {
                        return Observable.just(Mutation.setTempPost(post))
                    } else {
                        return Observable.empty()
                    }
                }
        case .setIsLoadTempPost:
            return Observable.just(Mutation.setIsLoadTempPost)
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
            newState.place = team?.place?[0] ?? ""
        case .updageAwayTeam(let team):
            newState.awayTeam = team
        case .updateAddText(let text):
            newState.addText = text
        case .updatePartyNumber(let num):
            newState.partyNumber = num
        case .savePost(let postId):
            newState.savePostResult = postId
            
        case .updateSaveButton:
            if newState.selecteDate != nil , newState.selecteTime != nil , newState.homeTeam != nil, newState.awayTeam != nil, newState.place != nil, newState.addText.trimmingCharacters(in: .whitespaces).isEmpty, newState.title.trimmingCharacters(in: .whitespaces).isEmpty {
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
        case .editPost(let postId):
            newState.savePostResult = postId
        case .setEditPost(let post):
            newState.editPost = post
        case .setTempPostResult:
            newState.tempPostResult = ()
        case .setIsLoadTempPost:
            newState.isLoadTempPost = true
        case .setTempPostId(let id):
            newState.tempPostId = id
        case .setTempPost(let post):
            newState.tempPost = post
            newState.loadTempPost = ()
        }
        return newState
    }
    private func validatePost(_ state: State) -> (RequestPost, SimpleUser)? {
        if let user = writer, let homeTeam = state.homeTeam, let awayTeam = state.awayTeam, let cheerTeam = state.cheerTeam, let place = state.place, let maxNum = state.partyNumber, let date = state.selecteDate, let time = state.selecteTime,
           !place.isEmpty, !state.title.isEmpty, !state.addText.isEmpty {
            let request = RequestPost(title: state.title, homeTeam: homeTeam, awayTeam: awayTeam, cheerTeam: cheerTeam, date: date, playTime: time.rawValue, location: place, maxPerson: maxNum, preferGender: state.selectedGender, preferAge: state.selectedAge, addInfo: state.addText)
            return (request, user)
        }
        return nil
    }
    
    func mappingRequestEditPost(_ post: RequestPost) -> RequestEditPost? {
        if let prePost = currentState.editPost {
            return RequestEditPost(id: prePost.id, title: post.title, homeTeam: post.homeTeam, awayTeam: post.awayTeam, cheerTeam: post.cheerTeam, date: post.date, playTime: post.playTime, location: post.location, currentPerson: prePost.currentPerson, maxPerson: post.maxPerson, preferGender: post.preferGender, preferAge: post.preferAge, addInfo: post.addInfo)
        }
        return nil
    }
}
