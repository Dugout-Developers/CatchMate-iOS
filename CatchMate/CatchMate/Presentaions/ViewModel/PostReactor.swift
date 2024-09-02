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
    private let setFavoriteUsecase: SetFavoriteUseCase
    init(postId: String, postloadUsecase: LoadPostUseCase, setfavoriteUsecase: SetFavoriteUseCase) {
        self.initialState = State()
        self.postId = postId
        LoggerService.shared.debugLog("-----------\(postId) detail Load------------")
        self.postloadUsecase = postloadUsecase
        self.setFavoriteUsecase = setfavoriteUsecase
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
            let favoriteList = SetupInfoService.shared.loadSimplePostIds()
            let index = favoriteList.firstIndex(where: {$0 == postId})
            return Observable.just(Mutation.setIsFavorite(index != nil ? true : false))
        case .changeFavorite(let state):
            return setFavoriteUsecase.setFavorite(state, postId)
                .map { result in
                    if result {
                        return Mutation.setIsFavorite(state)
                    }
                    return Mutation.setError(PresentationError.retryable(message: "찜하기 요청 실패. 다시 시도해주세요."))
                }
                .catch { error in
                    if let presentationError = error as? PresentationError {
                        return Observable.just(Mutation.setError(presentationError))
                    } else {
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
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
