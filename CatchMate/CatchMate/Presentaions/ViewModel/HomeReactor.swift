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
        case viewDidLoad
        case updateDateFilter(Date?)
        case updateTeamFilter([Team])
        case updateNumberFilter(Int?)
        case selectPost(String?)
        case loadNextPage
        case refreshPage
    }
    enum Mutation {
        case loadPost([SimplePost], append: Bool) 
        case setDateFilter(Date?)
        case setSelectedTeams([Team])
        case setSelectedPost(String?)
        case setNumberFilter(Int?)
        case setError(PresentationError?)
        case incrementPage
        case resetPage
        case setRefreshing(Bool)
    }
    struct State {
        var posts: [SimplePost] = []
        var dateFilterValue: Date?
        var selectedTeams: [Team] = []
        var selectedPost: String?
        var seletedNumberFilter: Int?
        var page: Int = 1
        var isLoadingNextPage: Bool = false
        var isRefreshing: Bool = false
        var error: PresentationError?
    }
    
    var initialState: State
    private let loadPostListUsecase: PostListLoadUseCase
    private let setupUseCase: SetupUseCase
    
    init(loadPostListUsecase: PostListLoadUseCase, setupUsecase: SetupUseCase) {
        self.initialState = State()
        self.loadPostListUsecase = loadPostListUsecase
        self.setupUseCase = setupUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateNumberFilter(let number):
            return Observable.concat([
                Observable.just(Mutation.resetPage),
                updateFiltersAndLoadPosts(number: number)
            ])
            
        case .updateDateFilter(let date):
            return Observable.concat([
                Observable.just(Mutation.resetPage),
                updateFiltersAndLoadPosts(date: date)
            ])

            
        case .updateTeamFilter(let teams):
            return Observable.concat([
                Observable.just(Mutation.resetPage),
                updateFiltersAndLoadPosts(teams: teams)
            ])
            
        case .selectPost(let post):
            return Observable.just(Mutation.setSelectedPost(post))
            
        case .viewDidLoad:
            return setupUseCase.setupInfo()
                .do(onNext: { result in
                    SetupInfoService.shared.saveUserInfo(UserInfoDTO(id: result.user.id, email: result.user.email, team: result.user.team.rawValue))
                    SetupInfoService.shared.saveFavoriteListIds(result.favoriteList)
                })
                .withUnretained(self)
                .flatMap({ reactor, _ in
                    return reactor.updateFiltersAndLoadPosts()
                })
                .catch { [weak self] error in
                    guard let self = self else { return .empty()}
                    return handlePresentationError(error)
                }
            
        case .loadNextPage:
            guard !currentState.isLoadingNextPage else { return .empty() }  // 중복 로딩 방지
            print("loadNextPage: \(currentState.page)")
            return loadPostListUsecase.loadPostList(pageNum: currentState.page, gudan: currentState.selectedTeams.map { $0.rawValue }, gameDate: currentState.dateFilterValue?.toString(format: "YYYY-MM-dd") ?? "", people: currentState.seletedNumberFilter ?? 0)
                .flatMap { list -> Observable<Mutation> in
                    if !list.isEmpty {
                        return Observable.concat([
                            Observable.just(Mutation.loadPost(list, append: true)),
                            Observable.just(Mutation.incrementPage)  // 결과가 있는 경우에만 페이지 증가
                        ])
                    }
                    return .empty()
                }
                .catch { [weak self] error in
                    guard let self = self else { return .empty() }
                    return self.handlePresentationError(error)
                }
        case .refreshPage:
            return Observable.concat([
                Observable.just(Mutation.setRefreshing(true)),
                Observable.just(Mutation.resetPage),
                updateFiltersAndLoadPosts(),
                Observable.just(Mutation.setRefreshing(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setDateFilter(let date):
            newState.dateFilterValue = date
            
        case let .setSelectedTeams(selectedTeams):
            newState.selectedTeams = selectedTeams
            
        case .loadPost(let posts, let append):
            if append {
                newState.posts.append(contentsOf: posts)
            } else {
                newState.page = 1
                newState.posts = posts
            }
            newState.isLoadingNextPage = false
            
        case .setSelectedPost(let post):
            newState.selectedPost = post
            
        case .setNumberFilter(let number):
            newState.seletedNumberFilter = number
            
        case .setError(let error):
            newState.error = error
            
        case .incrementPage:
            newState.page += 1
        case .resetPage:
            newState.page = 1
        case .setRefreshing(let refreshing):
            newState.isRefreshing = refreshing
        }
        return newState
    }
    
    // Helper Method: 필터 업데이트 및 포스트 로딩 처리
    private func updateFiltersAndLoadPosts(date: Date? = nil, teams: [Team]? = nil, number: Int? = nil) -> Observable<Mutation> {
        let gudan = (teams ?? currentState.selectedTeams).map { $0.rawValue }
        let requestDate = date?.toString(format: "YYYY-MM-dd") ?? currentState.dateFilterValue?.toString(format: "YYYY-MM-dd") ?? ""
        let requestNumber = number ?? currentState.seletedNumberFilter ?? 0
        print(currentState.page)
        let loadList = loadPostListUsecase.loadPostList(pageNum: 1, gudan: gudan, gameDate: requestDate, people: requestNumber)
            .map { list in
                Mutation.loadPost(list, append: false)
            }
            .catch { [weak self] error in
                guard let self = self else { return .empty()}
                return handlePresentationError(error)
            }
        
        return Observable.concat([
            teams != nil ? Observable.just(Mutation.setSelectedTeams(teams!)) : .empty(),
            date != nil ? Observable.just(Mutation.setDateFilter(date)) : .empty(),
            number != nil ? Observable.just(Mutation.setNumberFilter(number)) : .empty(),
            loadList,
            Observable.just(Mutation.incrementPage)
        ])
    }
    
    // Helper Method: 에러 처리
    private func handlePresentationError(_ error: Error) -> Observable<Mutation> {
        if let presentationError = error as? PresentationError {
            return Observable.just(Mutation.setError(presentationError))
        } else {
            return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
        }
    }
}
