//
//  ProfileEditReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

import UIKit
import RxSwift
import ReactorKit

final class ProfileEditReactor: Reactor {
    enum Action {
        case changeImage(UIImage?)
        case changeNickname(String)
        case changeTeam(Team)
        case changeCheerStyle(CheerStyles?)
        case editProfile
        case setError(PresentationError)
    }
    enum Mutation {
        case setProfileImage(UIImage?)
        case setNickName(String)
        case setNickNameCount(Int)
        case setTeam(Team)
        case setCheerStyle(CheerStyles?)
        case setEditProfileSuccess(Bool)
        case setError(PresentationError)
    }
    struct State {
        var profileImage: UIImage?
        var nickname: String
        var nickNameCount: Int
        var team: Team
        var cheerStyle: CheerStyles?
        var editProfileSucess: Bool = false
        var error: PresentationError?
    }
    
    var initialState: State
    private var currentUserInfo: User
    private let profileEditUseCase: ProfileEditUseCase
    init(user: User, usecase: ProfileEditUseCase) {
        self.currentUserInfo = user
        self.initialState = State(nickname: user.nickName, nickNameCount: user.nickName.count, team: user.team, cheerStyle: user.cheerStyle)
        self.profileEditUseCase = usecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .changeImage(let image):
            return Observable.just(Mutation.setProfileImage(image))
        case .changeNickname(let nickname):
            return Observable.concat([
                Observable.just(Mutation.setNickName(nickname)),
                Observable.just(Mutation.setNickNameCount(nickname.count))
            ])
        case .changeTeam(let team):
            return Observable.just(Mutation.setTeam(team))
        case .changeCheerStyle(let style):
            return Observable.just(Mutation.setCheerStyle(style))
        case .editProfile:
            let nickname = currentState.nickname
            let team = currentState.team
            let style = currentState.cheerStyle
            let image = currentState.profileImage
            return profileEditUseCase.editProfile(nickname: nickname, team: team, style: style, image: image)
                .map ({ state in
                    if state {
                        return Mutation.setEditProfileSuccess(state)
                    } else {
                        return Mutation.setError(.showToastMessage(message: "변경하는데 문제가 생겼습니다.\n다시 시도해주세요."))
                    }
                })
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .setError(let error):
            return Observable.just(Mutation.setError(error))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setProfileImage(let image):
            newState.error = nil
            newState.profileImage = image
        case .setNickName(let nickname):
            newState.error = nil
            newState.nickname = nickname
        case .setNickNameCount(let count):
            newState.error = nil
            newState.nickNameCount = count
        case .setTeam(let team):
            newState.error = nil
            newState.team = team
        case .setCheerStyle(let style):
            newState.error = nil
            newState.cheerStyle = style
        case .setEditProfileSuccess(let state):
            newState.error = nil
            newState.editProfileSucess = state
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
