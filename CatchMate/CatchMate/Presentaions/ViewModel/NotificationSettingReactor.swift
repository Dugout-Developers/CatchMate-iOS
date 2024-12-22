//
//  NotificationSettingReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 8/7/24.
//
import UIKit
import RxSwift
import ReactorKit



final class NotificationSettingReactor: Reactor {
    enum Action {
        case loadNotificationInfo
        case toggleSwitch((type: NotificationType, state: Bool))
        case setError(PresentationError?)
    }
    enum Mutation {
        case setAllAlarm(Bool)
        case setApplyAlarm(Bool)
        case setChatAlarm(Bool)
        case setEventAlarm(Bool)
        case setNotificationInfo(NotificationInfo)
        case setError(PresentationError?)
    }
    struct State {
        var allAlarm: Bool = false
        var applyAlarm: Bool = false
        var chatAlarm: Bool = false
        var eventAlarm: Bool = false
        var error: PresentationError?
    }
    
    var initialState: State
    private let notificationInfoUsecase: LoadNotificationIfoUseCase
    private let setNotificationUsecase: SetNotificationUseCase
    
    init(notificationInfoUsecase: LoadNotificationIfoUseCase, setNotificationUsecase: SetNotificationUseCase) {
        self.initialState = State()
        self.notificationInfoUsecase = notificationInfoUsecase
        self.setNotificationUsecase = setNotificationUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadNotificationInfo:
            return notificationInfoUsecase.loadNotificationInfo()
                .map { info in
                    return Mutation.setNotificationInfo(info)
                }
                .catch { error in
                    if let presentationError = error as? PresentationError {
                        return Observable.just(Mutation.setError(presentationError))
                    } else {
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
        case .toggleSwitch((let type, let state)):
            print("\(type.rawValue) state changed to \(state)")
            switch type {
            case .all:
                return setNotificationUsecase.execute(type: .all, state: state)
                    .map { newState in
                        return Mutation.setAllAlarm(newState)
                    }
            case .apply:
                return setNotificationUsecase.execute(type: .apply, state: state)
                    .map { newState in
                        return Mutation.setApplyAlarm(newState)
                    }
            case .chat:
                return setNotificationUsecase.execute(type: .chat, state: state)
                    .map { newState in
                        return Mutation.setChatAlarm(newState)
                    }
            case .event:
                return setNotificationUsecase.execute(type: .event, state: state)
                    .map { newState in
                        return Mutation.setEventAlarm(newState)
                    }
            }
        case .setError(let error):
            return Observable.just(.setError(error))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setAllAlarm(let state):
            newState.allAlarm = state
            newState.applyAlarm = state
            newState.chatAlarm = state
            newState.eventAlarm = state
        case .setApplyAlarm(let state):
            newState.applyAlarm = state
            if state == false { newState.allAlarm = false }
        case .setChatAlarm(let state):
            newState.chatAlarm = state
            if state == false { newState.allAlarm = false }
        case .setEventAlarm(let state):
            newState.eventAlarm = state
            if state == false { newState.allAlarm = false }
        case .setNotificationInfo(let info):
            newState.allAlarm = info.all
            newState.applyAlarm = info.apply
            newState.chatAlarm = info.chat
            newState.eventAlarm = info.event
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
