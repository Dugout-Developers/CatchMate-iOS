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

enum ApplyType {
    case none
    case applied
    case finished
    case chat
}

final class PostReactor: Reactor {
    enum Action {
        case loadPostDetails
        case loadIsFavorite
        case changeApplyButtonState(ApplyType)
        case apply(String?)
        case cancelApply
        case changeFavorite(Bool)
        case setError(PresentationError?)
    }
    enum Mutation {
        case setPost(Post?)
        case setApplyButtonState(ApplyType)
        case setIsFavorite(Bool)
        case setApplyInfo(MyApplyInfo?)
        case setError(PresentationError?)
    }
    struct State {
        // View의 state를 관리한다.
        var post: Post?
        var applyButtonState: ApplyType?
        var isFavorite: Bool = false
        var applyInfo: MyApplyInfo?
        var error: PresentationError?
    }
    var postId: String
    var initialState: State
    private let postDetailUsecase: PostDetailUseCase
    private let setFavoriteUsecase: SetFavoriteUseCase
    private let applyHandelerUsecase: ApplyHandleUseCase
    init(postId: String, postloadUsecase: PostDetailUseCase, setfavoriteUsecase: SetFavoriteUseCase, applyHandelerUsecase: ApplyHandleUseCase) {
        self.initialState = State()
        self.postId = postId
        LoggerService.shared.debugLog("-----------\(postId) detail Load------------")
        self.postDetailUsecase = postloadUsecase
        self.setFavoriteUsecase = setfavoriteUsecase
        self.applyHandelerUsecase = applyHandelerUsecase
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadPostDetails:
            return postDetailUsecase.loadPost(postId: postId)
                .flatMap { post, state in
                    var mutations: [Observable<Mutation>] = [
                        Observable.just(Mutation.setPost(post)),
                        Observable.just(Mutation.setApplyButtonState(state))
                    ]
                    if state == .applied {
                        let applyInfoMutation = self.postDetailUsecase.loadApplyInfo(postId: self.postId)
                            .map { info in
                                Mutation.setApplyInfo(info)
                            }
                        mutations.append(applyInfoMutation)
                    }
                    return Observable.concat(mutations)
                }
                .catch { error in
                    if let presentationError = error as? PresentationError {
                        return Observable.just(Mutation.setError(presentationError))
                    } else {
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
        case .changeApplyButtonState(let result):
            return Observable.just(Mutation.setApplyButtonState(result))
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
        case .apply(let text):
            return applyHandelerUsecase.apply(postId: postId, addText: text)
                .flatMap { id in
                    if id > 0 {
                        return Observable.concat([
                            Observable.just(Mutation.setApplyInfo(MyApplyInfo(enrollId: String(id), addInfo: text ?? ""))),
                            Observable.just(Mutation.setApplyButtonState(.applied))
                        ])
                    } else {
                        return Observable.just(Mutation.setError(.informational(message: "이미 보낸 신청입니다.")))
                    }
                }
                .catch { error in
                    if let presentationError = error as? PresentationError {
                        return Observable.just(Mutation.setError(presentationError))
                    } else {
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
        case .cancelApply:
            if let enrollId = currentState.applyInfo?.enrollId {
                return applyHandelerUsecase.cancelApplyPost(enrollId: enrollId)
                    .flatMap { _ in
                        return Observable.just(Mutation.setApplyButtonState(.none))
                    }
                    .catch { error in
                        if let presentationError = error as? PresentationError {
                            return Observable.just(Mutation.setError(presentationError))
                        } else {
                            return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                        }
                    }
            } else {
                return Observable.just(Mutation.setError(PresentationError.retryable(message: "요청을 실패했습니다. 다시 시도해주세요.")))
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setPost(let post):
            newState.post = post
            if let post = post {
                if post.maxPerson == post.currentPerson {
                    newState.applyButtonState = .finished
                }
            }
        case .setApplyButtonState(let state):
            newState.applyButtonState = state
            if state == .none {
                newState.applyInfo = nil
            }
        case .setIsFavorite(let state):
            newState.isFavorite = state
        case .setError(let error):
            newState.error = error
        case .setApplyInfo(let info):
            newState.applyInfo = info
        }
        return newState
    }
}
