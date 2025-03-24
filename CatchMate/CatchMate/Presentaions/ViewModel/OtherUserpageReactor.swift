//
//  OtherUserpageReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 8/12/24.
//

import RxSwift
import ReactorKit

final class OtherUserpageReactor: Reactor {
    enum Action {
        case loadPost
        case loadNextPage
        case blockUser
    }
    enum Mutation {
        case setPost(list: [SimplePost], isAppend: Bool)
        case incrementPage
        case resetPage
        case setIsLast(Bool)
        case setLoading(Bool)
        case setIsBlock(Bool)
        case setError(PresentationError?)
    }
    struct State {
        var posts: [SimplePost] = []
        var currentPage: Int = 0
        var isLast: Bool = false
        var isLoading: Bool = false
        var isBlock: Bool = false
        var error: PresentationError?
    }
    
    var initialState: State
    private let user: SimpleUser
    private let userPostUsecase: UserPostLoadUseCase
    private let blockUsecase: BlockUserUseCase
    init(user: SimpleUser, userPostUsecase: UserPostLoadUseCase, blockUsecase: BlockUserUseCase) {
        self.user = user
        self.userPostUsecase = userPostUsecase
        self.blockUsecase = blockUsecase
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadPost:
            if currentState.isBlock {
                return Observable.empty()
            }
            return userPostUsecase.loadPostList(userId: user.userId, page: 0)
                .flatMap { data -> Observable<Mutation> in
                    return Observable.concat([
                        Observable.just(Mutation.setLoading(true)),
                        Observable.just(.setPost(list: data.post, isAppend: false)),
                        Observable.just(.resetPage),
                        Observable.just(.setIsLast(data.isLast)),
                        Observable.just(Mutation.setLoading(false))
                    ])
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .loadNextPage:
            let nextPage = currentState.currentPage + 1
            if currentState.isBlock {
                return Observable.empty()
            }
            if !currentState.isLoading, currentState.isLast {
                return Observable.empty()
            }
            return userPostUsecase.loadPostList(userId: user.userId, page: nextPage)
                .flatMap { data -> Observable<Mutation> in
                    return Observable.concat([
                        Observable.just(Mutation.setLoading(true)),
                        Observable.just(.setPost(list: data.post, isAppend: true)),
                        Observable.just(.incrementPage),
                        Observable.just(.setIsLast(data.isLast)),
                        Observable.just(Mutation.setLoading(false))
                    ])
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .blockUser:
            return blockUsecase.blockUser(user.userId)
                .flatMap { _ in
                    return Observable.concat([
                        Observable.just(Mutation.setIsBlock(true)),
                        Observable.just(Mutation.setPost(list: [], isAppend: false))
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
        case .setPost(let posts, let isAppend):
            if isAppend {
                newState.posts.append(contentsOf: posts)
            } else {
                newState.posts = posts
            }
        case .incrementPage:
            newState.currentPage += 1
        case .resetPage:
            newState.currentPage = 0
        case .setIsLast(let state):
            newState.isLast = state
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setError(let error):
            newState.error = error
        case .setIsBlock(let state):
            newState.isBlock = state
        }
        return newState
    }
}
