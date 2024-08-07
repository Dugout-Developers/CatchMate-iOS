//
//  NotificationSettingReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 8/7/24.
//
import UIKit
import RxSwift
import ReactorKit


struct NotificationSetting {
    let title: String
    var isEnabled: Bool
}
final class NotificationSettingReactor: Reactor {
    enum Action {
        case toggleSwitch(IndexPath)
    }
    enum Mutation {
        case setSettingEnabled(IndexPath, Bool)

    }
    struct State {
        var settings: [NotificationSetting]
    }
    
    var initialState: State
    
    init() {
        self.initialState = State(settings: [
            NotificationSetting(title: "전체 알림", isEnabled: false),
            NotificationSetting(title: "직관 신청 알림", isEnabled: false),
            NotificationSetting(title: "채팅 알림", isEnabled: false),
            NotificationSetting(title: "이벤트 알림", isEnabled: false)
        ])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .toggleSwitch(indexPath):
            let currentSetting = currentState.settings[indexPath.row]
            let newSetting = !currentSetting.isEnabled
            return .just(.setSettingEnabled(indexPath, newSetting))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setSettingEnabled(indexPath, isEnabled):
            newState.settings[indexPath.row].isEnabled = isEnabled
        }
        return newState
    }
}
