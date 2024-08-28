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
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadPost:
            let list = Post.dummyPostData.map{SimplePost(post: $0)}
            return Observable.just(Mutation.setPost(list))
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
