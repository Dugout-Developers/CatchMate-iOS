//
//  RecevieMateReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 8/8/24.
//

import RxSwift
import ReactorKit

final class RecevieMateReactor: Reactor {
    enum PageActionType {
        case allList
        case detailList
    }
    enum Action {
        case loadReceiveAppliesAll
        case selectPost(Int?, String?)
        case acceptApply(String)
        case rejectApply(String)
        case loadNextPage
        case loadDetailNextPage
        case dismissDetail
    }
    enum Mutation {
        case setReceiveAppliesAll([RecivedApplies])
        case setSelectedPostApplies(Int?, [RecivedApplyData]?)
        case appendSelectedPostApplies([RecivedApplyData])
        case setError(PresentationError?)
        case acceptApply(String)
        case rejectApply(String)
        case incrementPage(PageActionType)
        case resetPage(PageActionType)
        case setIsLast(Bool, PageActionType)
        case setIsLoading(Bool)
    }
    struct State {
        var recivedApplies: [RecivedApplies] = []
        var selectedIndex: Int?
        var selectedPostApplies: [RecivedApplyData]?
        var currentPage: Int = 0
        var isLast: Bool = false
        var isLoading: Bool = false
        var detailIsLast: Bool = false
        var detailCurrentPage: Int = 0
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
            return receivedAllAppliesUsecase.execute(0)
                .flatMap { result in
                    return Observable.concat([
                        Observable.just(.setIsLoading(true)),
                        Observable.just(.resetPage(.allList)),
                        Observable.just(.setReceiveAppliesAll(result.applies)),
                        Observable.just(.setIsLast(result.isLast, .allList)),
                        Observable.just(.setIsLoading(false)),
                    ])
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .selectPost(let indexPath, let postId):
            if postId == nil {
                return Observable.just(Mutation.setSelectedPostApplies(nil, nil))
            }
            if let postId = postId, let intId = Int(postId) {
                resetNew(postId)
                let loadAppiles = receivedAppliesUsecase.execute(boardId: intId, page: 0)
                    .withUnretained(self)
                    .filter { _, list in !list.applies.isEmpty }
                    .flatMap({ reactor, list in
                        let applies = list.applies[0].applies
                        var index = indexPath
                        if indexPath == nil {
                            // Push로 접근 시
                            index = reactor.currentState.recivedApplies.firstIndex { applies in
                                return applies.post.id == postId
                            }
                        }
                        return Observable.concat([
                            Observable.just(Mutation.setSelectedPostApplies(index, applies)),
                            Observable.just(.setIsLast(list.isLast, .detailList))
                        ])
                    })
                    .catch { error in
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                return Observable.concat([
                    Observable.just(.setIsLoading(true)),
                    loadAppiles,
                    Observable.just(.resetPage(.detailList)),
                    Observable.just(.setIsLoading(false)),
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
        case .loadNextPage:
            let nextPage = currentState.currentPage + 1
            
            if currentState.isLast || currentState.isLoading {
                return Observable.empty()
            }
            if currentState.recivedApplies.isEmpty {
                return Observable.empty()
            }
            return receivedAllAppliesUsecase.execute(nextPage)
                .flatMap { result in
                    return Observable.concat([
                        Observable.just(.setIsLoading(true)),
                        Observable.just(.setReceiveAppliesAll(result.applies)),
                        Observable.just(.setIsLast(result.isLast, .allList)),
                        Observable.just(.incrementPage(.allList)),
                        Observable.just(.setIsLoading(false)),
                    ])
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .loadDetailNextPage:
            let nextPage = currentState.detailCurrentPage + 1
            
            if currentState.detailIsLast || currentState.isLoading {
                return Observable.empty()
            }
            
            if (currentState.selectedPostApplies ?? []).isEmpty {
                return Observable.empty()
            }
            guard let selectedIndex = currentState.selectedIndex else {
                return Observable.empty()
            }
            let postId = currentState.recivedApplies[safe: selectedIndex]?.post.id
            if postId == nil {
                return Observable.just(Mutation.setSelectedPostApplies(nil, nil))
            }
            if let postId = postId, let intId = Int(postId) {
                resetNew(postId)
                let loadAppiles = receivedAppliesUsecase.execute(boardId: intId, page: nextPage)
                    .withUnretained(self)
                    .filter { _, list in !list.applies.isEmpty }
                    .flatMap({ reactor, list in
                        let applies = list.applies[0].applies
                        return Observable.concat([
                            Observable.just(Mutation.appendSelectedPostApplies(applies)),
                            Observable.just(.setIsLast(list.isLast, .detailList))
                        ])
                    })
                    .catch { error in
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                return Observable.concat([
                    Observable.just(.setIsLoading(true)),
                    loadAppiles,
                    Observable.just(.incrementPage(.detailList)),
                    Observable.just(.setIsLoading(false)),
                ])
            } else {
                return Observable.just(Mutation.setError(PresentationError.showToastMessage(message: "요청에 실패했습니다. 다시 시도해주세요.")))
            }
        case .dismissDetail:
            return Observable.just(.resetPage(.detailList))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setReceiveAppliesAll(let result):
            newState.recivedApplies.append(contentsOf: result)
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
        case .incrementPage(let type):
            if type == .allList {
                newState.currentPage += 1
            } else {
                newState.detailCurrentPage += 1
            }
        case .resetPage(let type):
            if type == .allList {
                newState.currentPage = 0
            } else {
                newState.detailCurrentPage = 0
            }
        case .setIsLast(let isLast, let type):
            if type == .allList {
                newState.isLast = isLast
            } else {
                newState.detailIsLast = isLast
            }
        case .setIsLoading(let isLoading):
            newState.isLoading = isLoading
        case .appendSelectedPostApplies(let applies):
            newState.selectedPostApplies?.append(contentsOf: applies)
        }
        return newState
    }
    private func resetNew(_ id: String) {
        var list = currentState.recivedApplies
        if let index = list.firstIndex(where: {$0.post.id == id}) {
            list[index].changeNew()
        }
    }
}
