//
//  BlockUserReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 10/8/24.
//

import UIKit
import RxSwift
import ReactorKit

final class BlockUserReactor: Reactor {
    enum Action {
        case loadBlockUser
        case loadNextPage
        case unblockUser(Int)
    }
    enum Mutation {
        case setBlockUser(users: [SimpleUser], isAppend: Bool)
        case resetPage
        case incrementPage
        case setIsLast(Bool)
        case setLoading(Bool)
        case setError(PresentationError?)
    }
    struct State {
        var blockUsers: [SimpleUser] = []
        var currentPage: Int = 0
        var isLast: Bool = true
        var isLoading: Bool = true
        var error: PresentationError?
    }
    
    var initialState: State
    
    private let loadBlockUserUseCase: LoadBlockUsersUseCase
    private let unBlockUseCase: UnBlockUserUseCase
    init(loadBlockUserUseCase: LoadBlockUsersUseCase, unBlockUseCase: UnBlockUserUseCase) {
        self.loadBlockUserUseCase = loadBlockUserUseCase
        self.unBlockUseCase = unBlockUseCase
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadBlockUser:
            return loadBlockUserUseCase.loadBlockUsers(page: 0)
                .flatMap { users, isLast in
                    return Observable.concat([
                        Observable.just(.setLoading(true)),
                        Observable.just(.setBlockUser(users: users, isAppend: false)),
                        Observable.just(.resetPage),
                        Observable.just(.setIsLast(isLast)),
                        Observable.just(.setIsLast(false))
                    ])
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .unblockUser(let userId):
            return unBlockUseCase.unblockUser(userId)
                .flatMap { [weak self] _ in
                    guard let self else {
                        return Observable.just(Mutation.setError(PresentationError.showToastMessage(message: "차단 해제에 실패했어요")))
                    }
                    let newUsers = currentState.blockUsers.filter {
                        $0.userId != userId
                    }
                    return Observable.just(Mutation.setBlockUser(users: newUsers, isAppend: false))
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .loadNextPage:
            let nextPage = currentState.currentPage + 1
            return loadBlockUserUseCase.loadBlockUsers(page: nextPage)
                .flatMap { users, isLast in
                    return Observable.concat([
                        Observable.just(.setLoading(true)),
                        Observable.just(.setBlockUser(users: users, isAppend: true)),
                        Observable.just(.incrementPage),
                        Observable.just(.setIsLast(isLast)),
                        Observable.just(.setIsLast(false))
                    ])
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.error = nil
        switch mutation {
        case .setBlockUser(users: let users, isAppend: let isAppend):
            if isAppend {
                newState.blockUsers.append(contentsOf: users)
            } else {
                newState.blockUsers = users
            }
        case .resetPage:
            newState.currentPage = 0
        case .incrementPage:
            newState.currentPage += 1
        case .setIsLast(let state):
            newState.isLast = state
        case .setLoading(let state):
            newState.isLoading = state
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
