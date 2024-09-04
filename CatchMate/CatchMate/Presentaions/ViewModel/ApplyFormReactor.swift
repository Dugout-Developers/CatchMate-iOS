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
        case requestApplyForm(ApplyRequest)
        case setApplyInfo(MyApplyInfo)
        case cancelApply(String)
    }
    enum Mutation {
        case applyForm(MyApplyInfo)
        case cancelApply
        case setError(PresentationError)
    }
    struct State {
        var appleyResult: MyApplyInfo? // false 시 에러 핸들링
        var error: PresentationError?
    }
    
    var initialState: State
    private let applyUsecase: applyUseCase
    init(applyUsecase: applyUseCase, apply: MyApplyInfo?) {
        self.initialState = State(appleyResult: apply)
        self.applyUsecase = applyUsecase
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestApplyForm(let form):
            return applyUsecase.applyPost(form.applyPostId, addInfo: form.addInfo ?? "")
                .map { result in
                    return Mutation.applyForm(result)
                }
                .catch { error in
                    if let presentationError = error as? PresentationError {
                        return Observable.just(Mutation.setError(presentationError))
                    } else {
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }

        case .setApplyInfo(let apply):
            return Observable.just(Mutation.applyForm(apply))
        case .cancelApply(let enrollId):
            // MARK: - API 연결 필요
            print("\(enrollId) 신청 취소")
            return Observable.just(Mutation.cancelApply)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .applyForm(let result):
            newState.appleyResult = result
        case .setError(let error):
            newState.error = error
        case .cancelApply:
            newState.appleyResult = nil
        }
        return newState
    }
}
