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
        case setSelectedPost(String?)
        case setError(PresentationError?)
    }
    struct State {
        var favoritePost: [SimplePost] = []
        var selectedPost: String?
        var error: PresentationError?
    }
    
    var initialState: State
    private let favoriteListUsecase: LoadFavoriteListUseCase
    private let setFavoriteUsecase: SetFavoriteUseCase
    init(favoriteListUsecase: LoadFavoriteListUseCase, setFavoriteUsecase: SetFavoriteUseCase) {
        self.initialState = State()
        self.favoriteListUsecase = favoriteListUsecase
        self.setFavoriteUsecase = setFavoriteUsecase
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadFavoritePost:
            return favoriteListUsecase.execute()
                .map { list in
                    return Mutation.setFavoritePost(list)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .removeFavoritePost(let postId):
            return setFavoriteUsecase.execute(false, postId)
                .map { [weak self] _ in
                    guard let self = self else {
                        return Mutation.setError(PresentationError.showToastMessage(message: "찜삭제에 실패했습니다."))
                    }
                    let currentList = currentState.favoritePost.filter { $0.id != postId }
                    return Mutation.setFavoritePost(currentList)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .selectPost(let post):
            return Observable.just(Mutation.setSelectedPost(post))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setFavoritePost(let posts):
            newState.favoritePost = posts
        case .setSelectedPost(let postId):
            newState.selectedPost = postId
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
