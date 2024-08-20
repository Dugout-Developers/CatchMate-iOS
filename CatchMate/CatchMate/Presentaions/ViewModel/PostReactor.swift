//
//  PostReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 7/15/24.
//

import UIKit
import RxSwift
import ReactorKit

enum PostError: Error {
    case applyFailed
}
final class PostReactor: Reactor {
    enum Action {
        case loadPostDetails
        case loadIsFavorite
        case loadIsApplied
        case changeIsApplied(Bool)
        case changeFavorite(Bool)
        case setError(PresentationError?)
    }
    enum Mutation {
        case setPost(Post?)
        case setIsApplied(Bool)
        case setIsFavorite(Bool)
        case setError(PresentationError?)
    }
    struct State {
        // View의 state를 관리한다.
        var post: Post?
        var isApplied: Bool = false
        var isFinished: Bool = false
        var isFavorite: Bool = false
        var error: PresentationError?
    }
    var postId: String
    var initialState: State
    private let postloadUsecase: LoadPostUseCase
    init(postId: String, postloadUsecase: LoadPostUseCase) {
        self.initialState = State()
        self.postId = postId
        self.postloadUsecase = postloadUsecase
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadPostDetails:
            return postloadUsecase.loadPost(postId: postId)
                .map { post in
                    return Mutation.setPost(post)
                }
                .catch { error in
                    if let presentationError = error as? PresentationError {
                        return Observable.just(Mutation.setError(presentationError))
                    } else {
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }

        case .loadIsApplied:
            // TODO: - API UseCase 연결 시 신청 정보 가져와서 있는지 확인하고 result 설정
            let result = false
            return Observable.just(Mutation.setIsApplied(result))
        case .changeIsApplied(let result):
            return Observable.just(Mutation.setIsApplied(result))
        case .loadIsFavorite:
            // MARK: - API 연결 필요
            let index = Post.dummyFavoriteList.firstIndex(where: {$0.id == postId})
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
        case .setError(let error):
            return Observable.just(Mutation.setError(error))
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
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
