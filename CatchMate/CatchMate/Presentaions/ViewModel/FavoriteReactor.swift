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
        case removeFavoritePost(Post)
    }
    enum Mutation {
        case setFavoritePost([Post])
        case removeFavoritePost(Post)
    }
    struct State {
        var favoritePost: [Post] = []
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadFavoritePost:
            return Observable.just(Mutation.setFavoritePost(loadRandomList()))
        case .removeFavoritePost(let post):
            return Observable.just(Mutation.removeFavoritePost(post))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setFavoritePost(let posts):
            newState.favoritePost = posts
        case .removeFavoritePost(let post):
            var tempState = state
            if let index = state.favoritePost.firstIndex(of: post) {
                newState.favoritePost.remove(at: index)
            }
        }
        return newState
    }
    
    // MARK: - 임시 목업 데이터용 -> 데이터 연결 후 삭제
    private func loadRandomList() -> [Post] {
        var pickedNumbers = Set<Int>()
        
        while pickedNumbers.count < 4 {
            let randomNumber = Int.random(in: 0..<Post.dummyPostData.count)
            pickedNumbers.insert(randomNumber)
        }
        
        var result: [Post] = []
        pickedNumbers.forEach { index in
            result.append(Post.dummyPostData[index])
        }
        return result
    }
}
