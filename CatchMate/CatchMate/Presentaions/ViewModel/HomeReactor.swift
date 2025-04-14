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
        case setupUserInfo
        case loadGuestPosts
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
        case setIsLoadingNextPage(Bool)
        case setIsLast(Bool)
    }
    struct State {
        var posts: [SimplePost] = []
        var dateFilterValue: Date?
        var selectedTeams: [Team] = []
        var selectedPost: String?
        var seletedNumberFilter: Int?
        var page: Int = 0
        var isLoadingNextPage: Bool = false
        var isRefreshing: Bool = false
        var isLast: Bool = false
        var error: PresentationError?
    }
    
    var initialState: State
    private let loadPostListUsecase: PostListLoadUseCase
    private let setupUseCase: SetupUseCase
    private let isGuest: Bool
    init(loadPostListUsecase: PostListLoadUseCase, setupUsecase: SetupUseCase, isGuest: Bool) {
        self.isGuest = isGuest
        self.initialState = State()
        self.loadPostListUsecase = loadPostListUsecase
        self.setupUseCase = setupUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateNumberFilter(let number):
            return Observable.concat([
                Observable.just(Mutation.resetPage),
                updateFiltersAndLoadPosts(date: currentState.dateFilterValue, teams: currentState.selectedTeams, number: number)
            ])
            
        case .updateDateFilter(let date):
            return Observable.concat([
                Observable.just(Mutation.resetPage),
                updateFiltersAndLoadPosts(date: date, teams: currentState.selectedTeams, number: currentState.seletedNumberFilter)
            ])

            
        case .updateTeamFilter(let teams):
            return Observable.concat([
                Observable.just(Mutation.resetPage),
                updateFiltersAndLoadPosts(date: currentState.dateFilterValue, teams: teams, number: currentState.seletedNumberFilter)
            ])
            
        case .selectPost(let post):
            return Observable.just(Mutation.setSelectedPost(post))
            
        case .setupUserInfo:
            let cachedPosts: [SimplePost]? = CacheService.shared?.load(from: .postList)
             let isValid = CacheService.shared?.isCacheValid(for: .postList) ?? false

             // Step 1. 캐시가 있다면 바로 보여줌
             let cacheMutation: Observable<Mutation> = {
                 if let cached = cachedPosts {
                     return .just(.loadPost(cached, append: false))
                 } else {
                     return .empty()
                 }
             }()

             // Step 2. 유저 정보 세팅 (항상 필요)
             let userSetup = setupUseCase.setupInfo()
                 .do(onNext: { result in
                     SetupInfoService.shared.saveUserInfo(
                         UserInfoDTO(
                             id: String(result.id),
                             email: result.email,
                             team: result.team.rawValue,
                             nickname: result.nickName,
                             imageUrl: result.imageUrl
                         )
                     )
                 })
                 .map { _ in () }

             // Step 3. API 호출이 필요한 경우만 진행
             let apiFetchIfNeeded: Observable<Mutation> = {
                 // 캐시가 없거나 유효하지 않을 경우에만 호출
                 if cachedPosts == nil || !isValid {
                     return loadPostListUsecase.loadPostList(
                         pageNum: 0,
                         gudan: currentState.selectedTeams.map { $0.serverId },
                         gameDate: currentState.dateFilterValue?.toString(format: "YYYY-MM-dd") ?? "",
                         people: currentState.seletedNumberFilter ?? 0,
                         isGuest: isGuest
                     )
                     .map { data in
                         CacheService.shared?.save(data.post, to: .postList)
                         return .loadPost(data.post, append: false)
                     }
                     .catch { error in
                         return .just(.setError(ErrorMapper.mapToPresentationError(error)))
                     }
                 } else {
                     // 캐시가 유효하므로 API 호출 생략
                     return .empty()
                 }
             }()

             return Observable.concat([
                 cacheMutation,  // 보여주고
                 userSetup.flatMap { _ in apiFetchIfNeeded },  // 필요 시에만 새로 호출
                 .just(.incrementPage)
             ])
        case .loadGuestPosts:
            let date = currentState.dateFilterValue
            let teams = currentState.selectedTeams
            let number = currentState.seletedNumberFilter
            return updateFiltersAndLoadPosts(date: date, teams: teams, number: number)
        case .loadNextPage:
            guard !currentState.isLoadingNextPage else { return .empty() }  // 중복 로딩 방지
            guard !currentState.isLast else {
                // 마지막 페이지면 로딩X
                return .empty()
            }
            return loadPostListUsecase.loadPostList(pageNum: currentState.page, gudan: currentState.selectedTeams.map { $0.serverId }, gameDate: currentState.dateFilterValue?.toString(format: "YYYY-MM-dd") ?? "", people: currentState.seletedNumberFilter ?? 0, isGuest: isGuest)
                .flatMap { data -> Observable<Mutation> in
                    let list = data.post
                    if !list.isEmpty {
                        if data.isLast {
                            // 페이지 증가 없음
                            return Observable.concat([
                                Observable.just(Mutation.setIsLoadingNextPage(true)),
                                Observable.just(Mutation.loadPost(list, append: true)),
                                Observable.just(Mutation.setIsLast(true)),
                                Observable.just(Mutation.setIsLoadingNextPage(false))
                            ])
                        } else {
                            // Last가 아니라면 페이지 증가
                            return Observable.concat([
                                Observable.just(Mutation.setIsLoadingNextPage(true)),
                                Observable.just(Mutation.loadPost(list, append: true)),
                                Observable.just(Mutation.incrementPage),
                                Observable.just(Mutation.setIsLast(false)),
                                Observable.just(Mutation.setIsLoadingNextPage(false))
                            ])
                        }
                    }
                    return .empty()
                }
                .catch { error in
                    return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
                }
        case .refreshPage:
            return Observable.concat([
                Observable.just(Mutation.setRefreshing(true)),
                Observable.just(Mutation.resetPage),
                updateFiltersAndLoadPosts(
                    date: currentState.dateFilterValue,
                    teams: currentState.selectedTeams,
                    number: currentState.seletedNumberFilter,
                    shouldSaveCache: true 
                ),
                Observable.just(Mutation.setIsLast(false)),
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
                newState.page = 0
                newState.posts = posts
            }
            
        case .setSelectedPost(let post):
            newState.selectedPost = post
            
        case .setNumberFilter(let number):
            newState.seletedNumberFilter = number
            
        case .setError(let error):
            newState.error = error
            
        case .incrementPage:
            newState.page += 1
        case .resetPage:
            newState.page = 0
        case .setRefreshing(let refreshing):
            newState.isRefreshing = refreshing
        case .setIsLast(let state):
            newState.isLast = state
        case .setIsLoadingNextPage(let state):
            newState.isLoadingNextPage = state
        }
        return newState
    }
    
    // Helper Method: 필터 업데이트 및 포스트 로딩 처리
    private func updateFiltersAndLoadPosts(date: Date?, teams: [Team]?, number: Int?, shouldSaveCache: Bool = false) -> Observable<Mutation> {
        let gudan = (teams ?? currentState.selectedTeams).map { $0.serverId }
        let requestDate = date?.toString(format: "YYYY-MM-dd") ?? ""
        let requestNumber = number ?? 0
        let loadList = loadPostListUsecase.loadPostList(pageNum: 0, gudan: gudan, gameDate: requestDate, people: requestNumber, isGuest: isGuest)
            .map { data in
                let posts = data.post
                if shouldSaveCache {
                    CacheService.shared?.save(posts, to: .postList)
                }
                return Mutation.loadPost(posts, append: false)
            }
            .catch { error in
                return Observable.just(Mutation.setError(ErrorMapper.mapToPresentationError(error)))
            }
        
        return Observable.concat([
            teams != nil ? Observable.just(Mutation.setSelectedTeams(teams!)) : .empty(),
            Observable.just(Mutation.setDateFilter(date)),
            Observable.just(Mutation.setNumberFilter(number)),
            loadList,
            Observable.just(Mutation.incrementPage)
        ])
    }
}
