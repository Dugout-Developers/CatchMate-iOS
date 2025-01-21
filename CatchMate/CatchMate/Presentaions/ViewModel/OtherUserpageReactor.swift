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
    }
    enum Mutation {
        case setPost(list: [SimplePost], isAppend: Bool)
        case incrementPage
        case resetPage
        case setIsLast(Bool)
        case setLoading(Bool)
        case setError(PresentationError?)
    }
    struct State {
        var posts: [SimplePost] = []
        var currentPage: Int = 0
        var isLast: Bool = false
        var isLoading: Bool = false
        var error: PresentationError?
    }
    
    var initialState: State
    private let user: SimpleUser
    private let userPostUsecase: UserPostLoadUseCase
    init(user: SimpleUser, userPostUsecase: UserPostLoadUseCase) {
        self.user = user
        self.userPostUsecase = userPostUsecase
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadPost:
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
            print("loadNextPage")
            let nextPage = currentState.currentPage + 1
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
        }
        return newState
    }
}
