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
        case changeApplyButtonState(ApplyType)
        case apply(String?)
        case cancelApply
        case changeFavorite(Bool)
        case deletePost
        case setError(PresentationError?)
        case upPost
        case resetUpPostResult
    }
    enum Mutation {
        case setPost(Post?)
        case setApplyButtonState(ApplyType)
        case setIsFavorite(Bool)
        case setApplyInfo(MyApplyInfo?)
        case deletePost
        case setError(PresentationError?)
        case setUpPostResult(Bool?)
    }
    struct State {
        // View의 state를 관리한다.
        var post: Post?
        var applyButtonState: ApplyType?
        var isFavorite: Bool = false
        var applyInfo: MyApplyInfo?
        var isDelete: Bool = false
        var upPostResult: Bool?
        var error: PresentationError?
    }
    var postId: String
    var initialState: State
    private let postDetailUsecase: PostDetailUseCase
    private let setFavoriteUsecase: SetFavoriteUseCase
    private let applyUsecase: ApplyUseCase
    private let cancelApplyUsecase: CancelApplyUseCase
    private let deletePostUsecase: DeletePostUseCase
    private let upPostUsecase: UpPostUseCase
    
    init(postId: String, postloadUsecase: PostDetailUseCase, setfavoriteUsecase: SetFavoriteUseCase, applyUsecase: ApplyUseCase, cancelApplyUsecase: CancelApplyUseCase, postHandleUsecase: DeletePostUseCase, upPostUsecase: UpPostUseCase) {
        self.initialState = State()
        self.postId = postId
        LoggerService.shared.debugLog("-----------\(postId) detail Load------------")
        self.postDetailUsecase = postloadUsecase
        self.setFavoriteUsecase = setfavoriteUsecase
        self.applyUsecase = applyUsecase
        self.cancelApplyUsecase = cancelApplyUsecase
        self.deletePostUsecase = postHandleUsecase
        self.upPostUsecase = upPostUsecase
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadPostDetails:
            return postDetailUsecase.loadPost(postId: postId)
                .flatMap { post, state, favorite in
                    var mutations: [Observable<Mutation>] = [
                        Observable.just(Mutation.setPost(post)),
                        Observable.just(Mutation.setApplyButtonState(state)),
                        Observable.just(Mutation.setIsFavorite(favorite))
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
                    return Observable.just(Mutation.setError(error.toPresentationError()))
                }
        case .changeApplyButtonState(let result):
            return Observable.just(Mutation.setApplyButtonState(result))
        case .changeFavorite(let state):
            return setFavoriteUsecase.execute(state, postId)
                .map { result in
                    if result {
                        return Mutation.setIsFavorite(state)
                    }
                    return Mutation.setError(PresentationError.showToastMessage(message: "찜하기 요청 실패. 다시 시도해주세요."))
                }
                .catch { error in
                    return Observable.just(Mutation.setError(error.toPresentationError()))
                }
        case .setError(let error):
            return Observable.just(Mutation.setError(error))
        case .apply(let text):
            return applyUsecase.execute(postId: postId, addText: text)
                .flatMap { id in
                    if id > 0 {
                        return Observable.concat([
                            Observable.just(Mutation.setApplyInfo(MyApplyInfo(enrollId: String(id), addInfo: text ?? ""))),
                            Observable.just(Mutation.setApplyButtonState(.applied))
                        ])
                    } else {
                        return Observable.just(Mutation.setError(.showToastMessage(message: "이미 보낸 신청입니다.")))
                    }
                }
                .catch { error in
                    return Observable.just(Mutation.setError(error.toPresentationError()))
                }
        case .cancelApply:
            if let enrollId = currentState.applyInfo?.enrollId {
                return cancelApplyUsecase.execute(enrollId: enrollId)
                    .flatMap { _ in
                        return Observable.just(Mutation.setApplyButtonState(.none))
                    }
                    .catch { error in
                        return Observable.just(Mutation.setError(error.toPresentationError()))
                    }
            } else {
                return Observable.just(Mutation.setError(PresentationError.showToastMessage(message: "요청을 실패했습니다. 다시 시도해주세요.")))
            }
        case .deletePost:
            if let postId = Int(postId) {
                return deletePostUsecase.deletePost(postId: postId)
                    .flatMap { _ in
                        return Observable.just(Mutation.deletePost)
                    }
                    .catch { error in
                        return Observable.just(Mutation.setError(error.toPresentationError()))
                    }
            } else {
                return Observable.just(Mutation.setError(PresentationError.showToastMessage(message: "삭제 실패. 다시 시도해주세요.")))
            }
        case .upPost:
            return upPostUsecase.execute(postId)
                .map { result in
                    return Mutation.setUpPostResult(result)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(error.toPresentationError()))
                }
        case .resetUpPostResult:
            return Observable.just(Mutation.setUpPostResult(nil))
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
        case .deletePost:
            newState.isDelete = true
        case .setUpPostResult(let result):
            newState.upPostResult = result
        }
        return newState
    }
}
