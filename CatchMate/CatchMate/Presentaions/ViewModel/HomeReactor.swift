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
        case updateNumberFilter(Int?)
        case selectPost(String?)
    }
    enum Mutation {
        case loadPost([SimplePost])
        case setDateFilter(Date?)
        case setSelectedTeams([Team])
        case setSelectedPost(String?)
        case setNumberFilter(Int?)
        case setError(PresentationError?)
    }
    struct State {
        // View의 state를 관리한다.
        var posts: [SimplePost] = []
        var dateFilterValue: Date?
        var selectedTeams: [Team] = []
        var selectedPost: String?
        var seletedNumberFilter: Int?
        var error: PresentationError?
    }
    
    var initialState: State
    private let loadPostListUsecase: PostListLoadUseCase
    init(loadPostListUsecase: PostListLoadUseCase) {
        self.initialState = State()
        self.loadPostListUsecase = loadPostListUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateNumberFilter(let number):
            return Observable.just(Mutation.setNumberFilter(number))
        case .updateDateFilter(let date):
            let gudan = currentState.selectedTeams.map { $0.rawValue }.joined(separator: ",")
            var requestDate = ""
            if let date = date {
                requestDate = DateHelper.shared.toString(from: date, format: "YYYY-MM-dd")
            }
            let loadList = loadPostListUsecase.loadPostList(pageNum: 1, gudan: gudan, gameDate: requestDate)
                .map { list in
                    Mutation.loadPost(list)
                }
                .catch { error in
                    if let presentationError = error as? PresentationError {
                        Observable.just(Mutation.setError(presentationError))
                    } else {
                        Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
            return Observable.concat([
                Observable.just(Mutation.setDateFilter(date)),
                loadList
            ])
            
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
            let gudan = teams.map { $0.rawValue }.joined(separator: ",")
            var requestDate = ""
            if let date = currentState.dateFilterValue {
                requestDate = DateHelper.shared.toString(from: date, format: "YYYY-MM-dd")
            } else {
                requestDate = DateHelper.shared.toString(from: Date(), format: "YYYY-MM-dd")
            }
            let loadList = loadPostListUsecase.loadPostList(pageNum: 1, gudan: gudan, gameDate: requestDate)
                .map { list in
                    Mutation.loadPost(list)
                }
                .catch { error in
                    if let presentationError = error as? PresentationError {
                        Observable.just(Mutation.setError(presentationError))
                    } else {
                        Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
            return Observable.concat([
                Observable.just(Mutation.setSelectedTeams(teams)),
                loadList
            ])
        case .willAppear:
            return loadPostListUsecase.loadPostList(pageNum: 1, gudan: "다이노스", gameDate: "2024-08-16")
                .map { list in
                    return Mutation.loadPost(list)
                }
                .catch { error in
                    if let presentationError = error as? PresentationError {
                        return Observable.just(Mutation.setError(presentationError))
                    } else {
                        return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                    }
                }
            
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
            LoggerService.shared.debugLog("----------------loadHome----------------")
            if let savedAccessToken = KeychainService.getToken(for: .accessToken) {
                LoggerService.shared.debugLog("GetKeyChain Access Token: \(savedAccessToken)")
            }
            
            if let savedRefreshToken = KeychainService.getToken(for: .refreshToken) {
                LoggerService.shared.debugLog("GetKeyChain Refresh Token: \(savedRefreshToken)")
            }
            LoggerService.shared.debugLog("----------------------------------------")
            newState.posts = posts
        case .setSelectedPost(let post):
            newState.selectedPost = post
        case .setNumberFilter(let number):
            newState.seletedNumberFilter = number
        case .setError(let error):
            newState.error = error
        }
        return newState
    }
}
