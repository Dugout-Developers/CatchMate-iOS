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
        case loadNextPage
    }
    enum Mutation {
        case setAnnouncements(list: [Announcement], isAppend: Bool)
        case setSelectAnnouncement(Announcement?)
        case resetPage
        case incrementPage
        case setIsLast(Bool)
        case setLoading(Bool)
        case setError(PresentationError?)
    }
    struct State {
        var announcements: [Announcement] = []
        var selectedAnnouncement: Announcement? = nil
        var currentPage: Int = 0
        var isLoading: Bool = false
        var isLast: Bool = false
        var error: PresentationError?
    }
    
    var initialState: State
    private let loadNoticesUseCase: LoadNoticeListUseCase
    init(loadNoticesUseCase: LoadNoticeListUseCase) {
        self.initialState = State()
        self.loadNoticesUseCase = loadNoticesUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadAnnouncements:
            return loadNoticesUseCase.loadNotices(0)
                .flatMap { notice, isLast in
                    return Observable.concat([
                        Observable.just(Mutation.setLoading(true)),
                        Observable.just(.setAnnouncements(list: notice, isAppend: false)),
                        Observable.just(.resetPage),
                        Observable.just(.setIsLast(isLast)),
                        Observable.just(Mutation.setLoading(false))
                    ])
                }
                .catch { error in
                    return Observable.concat([
                        Observable.just(Mutation.setLoading(false)),
                        Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    ])
                }
        case .selectAnnouncement(let announcement):
            return Observable.just(Mutation.setSelectAnnouncement(announcement))
        case .loadNextPage:
            let nextPage = currentState.currentPage + 1
            if !currentState.isLoading || currentState.isLast {
                return Observable.empty()
            }
            if currentState.announcements.isEmpty {
                return Observable.empty()
            }
            return loadNoticesUseCase.loadNotices(nextPage)
                .flatMap { notice, isLast in
                    return Observable.concat([
                        Observable.just(Mutation.setLoading(true)),
                        Observable.just(.setAnnouncements(list: notice, isAppend: true)),
                        Observable.just(.incrementPage),
                        Observable.just(.setIsLast(isLast)),
                        Observable.just(Mutation.setLoading(false))
                    ])
                }
                .catch { error in
                    return Observable.concat([
                        Observable.just(Mutation.setLoading(false)),
                        Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    ])
                }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.error = nil
        switch mutation {
        case .setAnnouncements(let list, let isAppend):
            if isAppend {
                newState.announcements.append(contentsOf: list)
            } else {
                newState.announcements = list
            }
        case .setSelectAnnouncement(let announcement):
            newState.selectedAnnouncement = announcement
        case .resetPage:
            newState.currentPage = 0
        case .incrementPage:
            newState.currentPage += 1
        case .setIsLast(let state):
            newState.isLast = state
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
