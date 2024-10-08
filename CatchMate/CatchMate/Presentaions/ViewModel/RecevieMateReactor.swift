//
//  RecevieMateReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 8/8/24.
//

import RxSwift
import ReactorKit

final class RecevieMateReactor: Reactor {
    enum Action {
        case loadReceiveAppliesAll
        case selectPost(String?)
        case acceptApply(String)
        case rejectApply(String)
    }
    enum Mutation {
        case setReceiveAppliesAll([RecivedApplies])
        case setSelectedPostApplies([RecivedApplyData]?)
        case setError(PresentationError?)
        case acceptApply(String)
        case rejectApply(String)
    }
    struct State {
        var recivedApplies: [RecivedApplies] = []
        var selectedPostApplies: [RecivedApplyData]?
        var error: PresentationError?
    }
    
    var initialState: State
    private let recivedAppliesUsecase: ReceivedAppliesUseCase
    init(recivedAppliesUsecase: ReceivedAppliesUseCase) {
        self.initialState = State()
        self.recivedAppliesUsecase = recivedAppliesUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadReceiveAppliesAll:
            return recivedAppliesUsecase.loadReceivedAppliesAll()
                .map { result in
                    return Mutation.setReceiveAppliesAll(result)
                }
                .catch { error in
                    if let presentationError = error as? PresentationError {
                        return Observable.just(Mutation.setError(presentationError))
                    } else {
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
        case .selectPost(let postId):
            if let postId = postId, let intId = Int(postId) {
                return recivedAppliesUsecase.loadRecivedApplies(boardId: intId)
                    .map { result in
                        return Mutation.setSelectedPostApplies(result)
                    }
                    .catch { error in
                        if let presentationError = error as? PresentationError {
                            return Observable.just(Mutation.setError(presentationError))
                        } else {
                            return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                        }
                    }
            } else {
                return Observable.just(Mutation.setError(PresentationError.informational(message: "요청에 실패했습니다. 다시 시도해주세요.")))
            }
        case .acceptApply(let enrollId):
            return recivedAppliesUsecase.acceptApply(enrollId: enrollId)
                .map { result in
                    if result {
                        return Mutation.acceptApply(enrollId)
                    } else {
                        return Mutation.setError(PresentationError.informational(message: "다시 시도해주세요."))
                    }
                }
                .catch { error in
                    if let presentationError = error as? PresentationError {
                        return Observable.just(Mutation.setError(presentationError))
                    } else {
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
        case .rejectApply(let enrollId):
            return recivedAppliesUsecase.rejectApply(enrollId: enrollId)
                .map { result in
                    if result {
                        return Mutation.acceptApply(enrollId)
                    } else {
                        return Mutation.setError(PresentationError.informational(message: "다시 시도해주세요."))
                    }
                }
                .catch { error in
                    if let presentationError = error as? PresentationError {
                        return Observable.just(Mutation.setError(presentationError))
                    } else {
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setReceiveAppliesAll(let result):
            newState.recivedApplies = result
            newState.error = nil
        case .setSelectedPostApplies(let applies):
            newState.selectedPostApplies = applies
            newState.error = nil
        case .setError(let error):
            newState.error = error
        case .acceptApply(let enrollId), .rejectApply(let enrollId):
            newState.selectedPostApplies = currentState.selectedPostApplies?.filter({ $0.enrollId != enrollId })
        }
        return newState
    }
}
