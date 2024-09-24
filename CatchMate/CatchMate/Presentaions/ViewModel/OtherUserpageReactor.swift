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
    }
    enum Mutation {
        case setPost([SimplePost])
        case setError(PresentationError?)
    }
    struct State {
        var posts: [SimplePost] = []
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
            if let userId = Int(user.userId) {
                return userPostUsecase.loadPostList(userId: userId, page: 1)
                    .map { list in
                        return Mutation.setPost(list)
                    }
                    .catch { error in
                        if let presentationError = error as? PresentationError {
                            return Observable.just(Mutation.setError(presentationError))
                        } else {
                            return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                        }
                    }
            } else {
                return Observable.just(Mutation.setError(PresentationError.showErrorPage(message: "정보를 불러올 수 없습니다. 다시 시도해주세요.")))
            }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setPost(let posts):
            newState.posts = posts
            newState.error = nil
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
