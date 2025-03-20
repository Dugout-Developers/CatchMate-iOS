//
//  NotificationListReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 1/7/25.
//

import UIKit
import RxSwift
import ReactorKit

final class NotificationListReactor: Reactor {
    enum Action {
        case loadList
        case deleteNoti(Int) // indexPath 전달
        case selectNoti(NotificationList?)
        case loadNextPage
    }
    enum Mutation {
        case setList([NotificationList])
        case updateList([NotificationList])
        case setSelectedNoti(NotificationList?)
        case setError(PresentationError?)
        case incrementPage
        case resetPage
        case setIsLast(Bool)
        case setIsLoading(Bool)
    }
    struct State {
        var notifications: [NotificationList] = []
        var selectedNoti: NotificationList?
        var error: PresentationError?
        var currentPage: Int = 0
        var isLast: Bool = false
        var isLoading: Bool = false
    }
    
    var initialState: State
    private let loadNotiUsecase: LoadNotificationListUseCase
    private let deleteNotiUsecase: DeleteNotificationUseCase
    
    init(loadlistUsecase: LoadNotificationListUseCase, deleteNotiUsecase: DeleteNotificationUseCase) {
        self.initialState = State()
        self.loadNotiUsecase = loadlistUsecase
        self.deleteNotiUsecase = deleteNotiUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadList:
            if !currentState.notifications.isEmpty {
                return Observable.empty()
            }
            return loadNotiUsecase.execute(0)
                .flatMap { data in
                    return Observable.concat([
                        Observable.just(.setIsLoading(true)),
                        Observable.just(.setList(data.list)),
                        Observable.just(.resetPage),
                        Observable.just(.setIsLast(data.isLast)),
                        Observable.just(.setIsLoading(false))
                    ])
                }
                .catch {
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError($0)))
                }
        case .deleteNoti(let indexPath):
            let noti = currentState.notifications[indexPath]
            return deleteNotiUsecase.deleteNotification(noti.id)
                .withUnretained(self)
                .map { vc, _ in
                    var list = vc.currentState.notifications
                    list.remove(at: indexPath)
                    return Mutation.updateList(list)
                }
                .catch {
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError($0)))
                }
        case .selectNoti(let noti):
            if noti?.type == .inquiry {
                return Observable.just(Mutation.setSelectedNoti(noti))
            }
            guard let noti = noti, let id = Int(noti.id) else {
                return Observable.just(Mutation.setSelectedNoti(nil))
            }
            return loadNotiUsecase.readNotification(id)
                .map { _ in
                    return Mutation.setSelectedNoti(noti)
                }
        case .loadNextPage:
            let nextPage = currentState.currentPage + 1
            if currentState.isLast || currentState.isLoading {
                return Observable.empty()
            }
            if currentState.notifications.isEmpty {
                return Observable.empty()
            }
            return loadNotiUsecase.execute(nextPage)
                .flatMap { list, isLast in
                    return Observable.concat([
                        Observable.just(.setIsLoading(true)),
                        Observable.just(.setList(list)),
                        Observable.just(.incrementPage),
                        Observable.just(.setIsLast(isLast)),
                        Observable.just(.setIsLoading(false))
                    ])
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.error = nil
        switch mutation {
        case .updateList(let list):
            newState.notifications = list
        case .setList(let list):
            newState.notifications.append(contentsOf: list)
        case .setError(let error):
            newState.error = error
        case .setSelectedNoti(let noti):
            newState.selectedNoti = noti
        case .incrementPage:
            newState.currentPage += 1
        case .resetPage:
            newState.currentPage = 0
        case .setIsLast(let isLast):
            newState.isLast = isLast
        case .setIsLoading(let isLoading):
            newState.isLoading = isLoading
        }
        return newState
    }
}
