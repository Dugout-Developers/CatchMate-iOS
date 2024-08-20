//
//  FavoriteReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 7/11/24.
//

import UIKit
import RxSwift
import ReactorKit

final class FavoriteReactor: Reactor {
    enum Action {
        case loadFavoritePost
        case removeFavoritePost(String)
        case selectPost(String?)
    }
    enum Mutation {
        case setFavoritePost([SimplePost])
        case removeFavoritePost(String)
        case setSelectedPost(String?)
    }
    struct State {
        var favoritePost: [SimplePost] = []
        var selectedPost: String?
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadFavoritePost:
            return Observable.just(Mutation.setFavoritePost([]))
        case .removeFavoritePost(let post):
            // TODO: - API 연결로 변경 필요
//            if let index = Post.dummyFavoriteList.firstIndex(of: post) {
//                Post.dummyFavoriteList.remove(at: index)
//            }
            return Observable.just(Mutation.removeFavoritePost(""))
        case .selectPost(let post):
            return Observable.just(Mutation.setSelectedPost(post))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setFavoritePost(let posts):
            newState.favoritePost = posts
        case .removeFavoritePost(let post):
            break
//            if let index = state.favoritePost.firstIndex(of: post) {
//                newState.favoritePost.remove(at: index)
//            }
        case .setSelectedPost(let postId):
            newState.selectedPost = postId
        }
        return newState
    }
}
