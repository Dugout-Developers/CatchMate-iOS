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
        case loadNextPage
    }
    enum Mutation {
        case setFavoritePost(list: [SimplePost], isAppend: Bool)
        case setSelectedPost(String?)
        case setError(PresentationError?)
        case incrementPage
        case resetPage
        case setIsLast(Bool)
    }
    struct State {
        var favoritePost: [SimplePost] = []
        var selectedPost: String?
        var currentPage: Int = 0
        var isLast: Bool = false
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
            return favoriteListUsecase.execute(page: 0)
                .flatMap { data -> Observable<Mutation> in
                    return Observable.concat([
                        Observable.just(.setFavoritePost(list: data.post, isAppend: false)),
                        Observable.just(.resetPage),
                        Observable.just(.setIsLast(data.isLast))
                    ])
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
                    return Mutation.setFavoritePost(list: currentList, isAppend: false)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .selectPost(let post):
            return Observable.just(Mutation.setSelectedPost(post))
        case .loadNextPage:
            let nextPage = currentState.currentPage + 1
            if currentState.isLast {
                return Observable.empty()
            }
            return favoriteListUsecase.execute(page: nextPage)
                .flatMap { data -> Observable<Mutation> in
                    return Observable.concat([
                        Observable.just(.setFavoritePost(list: data.post, isAppend: true)),
                        Observable.just(.incrementPage),
                        Observable.just(.setIsLast(data.isLast))
                    ])
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setFavoritePost(let posts, let isAppend):
            if isAppend {
                newState.favoritePost.append(contentsOf: posts)
            } else {
                newState.favoritePost = posts
            }
        case .setSelectedPost(let postId):
            newState.selectedPost = postId
        case .setError(let error):
            newState.error = error
        case .incrementPage:
            newState.currentPage += 1
        case .resetPage:
            newState.currentPage = 0
        case .setIsLast(let state):
            newState.isLast = state
        }
        return newState
    }
}
