//
//  ApplyFormReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 7/17/24.
//

import UIKit
import RxSwift
import ReactorKit

final class ApplyFormReactor: Reactor {
    enum Action {
        case loadPostDetails
        case requestApplyForm(Apply)
    }
    enum Mutation {
        case setPost(Post?)
        case applyForm(Bool)
    }
    struct State {
        // View의 state를 관리한다.
        var postId: String
        var post: Post?
        var appleyResult: Bool? // false 시 에러 핸들링
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
        case .requestApplyForm(let form):
           // TODO: API UseCase 처리 후 결과 값 반환
            return Observable.just(Mutation.applyForm(true))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setPost(let post):
            newState.post = post
        case .applyForm(let result):
            newState.appleyResult = result
        }
        return newState
    }
}
