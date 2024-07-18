//
//  PostReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 7/15/24.
//

import UIKit
import RxSwift
import ReactorKit

final class PostReactor: Reactor {
    enum Action {
        case loadPostDetails
        case loadIsFavorite
        case loadIsApplied
        case changeIsApplied(Bool)
        case changeFavorite(Bool)
    }
    enum Mutation {
        case setPost(Post?)
        case setIsApplied(Bool)
        case setIsFavorite(Bool)
    }
    struct State {
        // View의 state를 관리한다.
        var postId: String
        var post: Post?
        var isApplied: Bool = false
        var isFinished: Bool = false
        var isFavorite: Bool = false
    }
    
    var initialState: State
    
    init(postId: String) {
        self.initialState = State(postId: postId)
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadPostDetails:
            // TODO: - API UseCase 연결 시 post load로 변경하기
            if let index = Post.dummyPostData.firstIndex(where: {$0.id == initialState.postId}) {
                return Observable.just(Mutation.setPost(Post.dummyPostData[index]))
            } else {
                return Observable.just(Mutation.setPost(nil))
            }
        case .loadIsApplied:
            // TODO: - API UseCase 연결 시 신청 정보 가져와서 있는지 확인하고 result 설정
            let result = Bool.random()
            return Observable.just(Mutation.setIsApplied(result))
        case .changeIsApplied(let result):
            return Observable.just(Mutation.setIsApplied(result))
        case .loadIsFavorite:
            let index = Post.dummyFavoriteList.firstIndex(where: {$0.id == initialState.postId})
            return Observable.just(Mutation.setIsFavorite(index != nil ? true : false))
        case .changeFavorite(let state):
            if state {
                if let post = currentState.post, !Post.dummyFavoriteList.contains(post) {
                    Post.dummyFavoriteList.append(post)
                }
            } else {
                if let post = currentState.post, let index = Post.dummyFavoriteList.firstIndex(of: post) {
                    Post.dummyFavoriteList.remove(at: index)
                }
            }
            return Observable.just(Mutation.setIsFavorite(state))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setPost(let post):
            newState.post = post
            if let post = post {
                if post.maxPerson == post.currentPerson {
                    newState.isFinished = true
                }
            }
        case .setIsApplied(let state):
            newState.isApplied = state
        case .setIsFavorite(let state):
            print(state)
            newState.isFavorite = state
        }
        return newState
    }
}
