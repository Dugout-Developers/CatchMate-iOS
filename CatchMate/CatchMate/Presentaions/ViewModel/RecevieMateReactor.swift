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
        case selectPost(Int?, String?)
        case acceptApply(String)
        case rejectApply(String)
    }
    enum Mutation {
        case setReceiveAppliesAll([RecivedApplies])
        case setSelectedPostApplies(Int?, [RecivedApplyData]?)
        case setError(PresentationError?)
        case acceptApply(String)
        case rejectApply(String)
    }
    struct State {
        var recivedApplies: [RecivedApplies] = []
        var selectedIndex: Int?
        var selectedPostApplies: [RecivedApplyData]?
        var currentPage: Int = 0
        var isLast: Bool = false
        var error: PresentationError?
    }
    
    var initialState: State
    private let receivedAppliesUsecase: LoadReceivedAppliesUseCase
    private let receivedAllAppliesUsecase: LoadAllReceiveAppliesUseCase
    private let applyManageUsecase: ApplyManageUseCase
    init(receivedAppliesUsecase: LoadReceivedAppliesUseCase, receivedAllAppliesUsecase: LoadAllReceiveAppliesUseCase, applyManageUsecase: ApplyManageUseCase) {
        self.initialState = State()
        self.receivedAppliesUsecase = receivedAppliesUsecase
        self.receivedAllAppliesUsecase = receivedAllAppliesUsecase
        self.applyManageUsecase = applyManageUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadReceiveAppliesAll:
            return receivedAllAppliesUsecase.execute()
                .map { result in
                    return Mutation.setReceiveAppliesAll(result.applies)
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .selectPost(let indexPath, let postId):
            if postId == nil {
                return Observable.just(Mutation.setSelectedPostApplies(nil, nil))
            }
            if let postId = postId, let intId = Int(postId) {
                let list = resetNew(postId)
                let loadAppiles = receivedAppliesUsecase.execute(boardId: intId)
                    .withUnretained(self)
                    .filter { _, list in !list.applies.isEmpty }
                    .map({ reactor, list in
                        let applies = list.applies[0].applies
                        var index = indexPath
                        if indexPath == nil {
                            // Push로 접근 시
                            index = reactor.currentState.recivedApplies.firstIndex { applies in
                                return applies.post.id == postId
                            }
                        }
                        return Mutation.setSelectedPostApplies(index, applies)
                    })
                    .catch { error in
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                return Observable.concat([
                    Observable.just(Mutation.setReceiveAppliesAll(list)),
                    loadAppiles
                ])
            } else {
                return Observable.just(Mutation.setError(PresentationError.showToastMessage(message: "요청에 실패했습니다. 다시 시도해주세요.")))
            }
        case .acceptApply(let enrollId):
            return applyManageUsecase.execute(type: .accept, enrollId: enrollId)
                .map { result in
                    if result {
                        return Mutation.acceptApply(enrollId)
                    } else {
                        return Mutation.setError(PresentationError.showToastMessage(message: "요청에 실패했습니다. 다시 시도해주세요."))
                    }
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .rejectApply(let enrollId):
            return applyManageUsecase.execute(type: .reject, enrollId: enrollId)
                .map { result in
                    if result {
                        return Mutation.rejectApply(enrollId)
                    } else {
                        return Mutation.setError(PresentationError.showToastMessage(message: "요청에 실패했습니다. 다시 시도해주세요."))
                    }
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setReceiveAppliesAll(let result):
            newState.recivedApplies = result
            newState.error = nil
        case .setSelectedPostApplies(let index, let applies):
            newState.selectedIndex = index
            newState.selectedPostApplies = applies
            newState.error = nil
        case .setError(let error):
            newState.error = error
        case .acceptApply(let enrollId), .rejectApply(let enrollId):
            let newApplies = currentState.selectedPostApplies?.filter({ $0.enrollId != enrollId })
            newState.selectedPostApplies = newApplies
            if let index = currentState.selectedIndex, let newApplies = newApplies {
                if newApplies.isEmpty {
                    newState.recivedApplies.remove(at: index)
                } else {
                    newState.recivedApplies[index].applies = newApplies
                }
            }
        }
        return newState
    }
    private func resetNew(_ id: String) -> [RecivedApplies] {
        var list = currentState.recivedApplies
        if let index = list.firstIndex(where: {$0.post.id == id}) {
            list[index].changeNew()
        }
        return list
    }
}
