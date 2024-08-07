//
//  AnnouncementsReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 8/8/24.
//

import RxSwift
import ReactorKit

final class AnnouncementsReactor: Reactor {
    enum Action {
        case loadAnnouncements
        case selectAnnouncement(Announcement?)
    }
    enum Mutation {
        case setAnnouncements([Announcement])
        case setSelectAnnouncement(Announcement?)
    }
    struct State {
        var announcements: [Announcement] = []
        var selectedAnnouncement: Announcement? = nil
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadAnnouncements:
            return Observable.just(Mutation.setAnnouncements(Announcement.dummyData))
        case .selectAnnouncement(let announcement):
            return Observable.just(Mutation.setSelectAnnouncement(announcement))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setAnnouncements(let list):
            newState.announcements = list
        case .setSelectAnnouncement(let announcement):
            newState.selectedAnnouncement = announcement
        }
        return newState
    }
}
