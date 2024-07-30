//
//  HomeReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit
import RxSwift
import ReactorKit

final class HomeReactor: Reactor {
    enum Action {
        case willAppear
        case updateDateFilter(Date?)
        case toggleTeamSelection(Team?)
        case updateTeamFilter([Team])
        case selectPost(Post?)
    }
    enum Mutation {
        // Action과 State 사이의 다리역할이다.
        // action stream을 변환하여 state에 전달한다.
        case loadPost([Post])
        case setDateFilter(Date?)
        case setSelectedTeams([Team])
        case setSelectedPost(Post?)
    }
    struct State {
        // View의 state를 관리한다.
        var posts: [Post] = []
        var dateFilterValue: Date?
        var selectedTeams: [Team] = []
        var selectedPost: Post?
        var error: Error?
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateDateFilter(let date):
            return Observable.just(Mutation.setDateFilter(date))
            
        case let .toggleTeamSelection(team):
            var updatedTeams = currentState.selectedTeams
            guard let team = team else {
                return Observable.just(Mutation.setSelectedTeams([]))
            }
            if let index = updatedTeams.firstIndex(of: team) {
                updatedTeams.remove(at: index)
            } else {
                updatedTeams.append(team)
            }
            return Observable.just(Mutation.setSelectedTeams(updatedTeams))
        case .updateTeamFilter(let teams):
            return Observable.just(Mutation.setSelectedTeams(teams))
        case .willAppear:
            return Observable.just(Mutation.loadPost(Post.dummyPostData))

        case .selectPost(let post):
            return Observable.just(Mutation.setSelectedPost(post))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setDateFilter(let date):
            newState.dateFilterValue = date
        case let .setSelectedTeams(selectedTeams):
            newState.selectedTeams = selectedTeams
        case .loadPost(let posts):
            if let savedAccessToken = KeychainService.getToken(for: .accessToken) {
                print("Access Token: \(savedAccessToken)")
            }

            if let savedRefreshToken = KeychainService.getToken(for: .refreshToken) {
                print("Refresh Token: \(savedRefreshToken)")
            }
            newState.posts = posts
        case .setSelectedPost(let post):
            newState.selectedPost = post
        }
        return newState
    }
}
