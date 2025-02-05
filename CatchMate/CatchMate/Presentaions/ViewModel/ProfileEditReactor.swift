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
        case endEditNickname
        case changeTeam(Team)
        case changeCheerStyle(CheerStyles?)
        case editProfile
        case setError(PresentationError)
    }
    enum Mutation {
        case setProfileImage(UIImage?)
        case setNickName(String)
        case endEditingNickname(Bool?)
        case setNickNameCount(Int)
        case setTeam(Team)
        case setCheerStyle(CheerStyles?)
        case setEditProfileSuccess(Bool)
        case setError(PresentationError)
    }
    struct State {
        var profileImage: UIImage?
        var nickname: String
        var nickNameValidate: ValidatCase = .none
        var nickNameCount: Int
        var team: Team
        var cheerStyle: CheerStyles?
        var editProfileSucess: Bool = false
        var error: PresentationError?
    }
    
    var initialState: State
    private var currentUserInfo: User
    private let profileEditUseCase: ProfileEditUseCase
    private let nicknameUsecase: NicknameCheckUseCase
    init(user: User, usecase: ProfileEditUseCase, nicknameUsecase: NicknameCheckUseCase) {
        self.currentUserInfo = user
        self.initialState = State(nickname: user.nickName, nickNameCount: user.nickName.count, team: user.team, cheerStyle: user.cheerStyle)
        self.profileEditUseCase = usecase
        self.nicknameUsecase = nicknameUsecase
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
        case .endEditNickname:
            let currentNickName = currentState.nickname
            if currentNickName == currentUserInfo.nickName {
                return Observable.just(.endEditingNickname(nil))
            }
            if !currentNickName.isEmpty {
                return nicknameUsecase.execute(currentState.nickname)
                    .flatMap { result in
                        return Observable.just(Mutation.endEditingNickname(result))
                    }
            }
            return Observable.just(Mutation.endEditingNickname(nil))
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
        newState.error = nil
        switch mutation {
        case .setProfileImage(let image):
            newState.profileImage = image
        case .setNickName(let nickname):
            newState.nickname = nickname
        case .endEditingNickname(let state):
            if let state = state {
                newState.nickNameValidate = state ? .success : .failed
            } else {
                newState.nickNameValidate = .none
            }
        case .setNickNameCount(let count):
            newState.nickNameCount = count
        case .setTeam(let team):
            newState.team = team
        case .setCheerStyle(let style):
            newState.cheerStyle = style
        case .setEditProfileSuccess(let state):
            if state {
                let nickName = currentState.nickname
                let cheerTeam = currentState.team.rawValue
                SetupInfoService.shared.saveUserInfo(type: .nickName, nickName)
                SetupInfoService.shared.saveUserInfo(type: .team, cheerTeam)
            }
            newState.editProfileSucess = state
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
