//
//  ReportReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 10/3/24.
//

import RxSwift
import ReactorKit

final class ReportReactor: Reactor {
    enum Action {
        case selectReportType(ReportType)
        case changeContent(String)
        case reportUser
    }
    enum Mutation {
        case setError(PresentationError?)
        case setFinishedReport(Bool)
        case setContent(String)
        case setReportType(ReportType?)
    }
    struct State {
        var error: PresentationError?
        var reportType: ReportType?
        var content: String = ""
        var reportButtonEnable: Bool = false
        var finishedReport: Bool = false
    }
    
    var initialState: State
    private let user: SimpleUser
    private let reportUseCase: ReportUserUseCase
    init(user: SimpleUser, reportUseCase: ReportUserUseCase) {
        self.user = user
        self.reportUseCase = reportUseCase
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectReportType(let type):
            return Observable.just(.setReportType(type))
        case .changeContent(let content):
            return Observable.just(.setContent(content))
        case .reportUser:
            guard let reportType = currentState.reportType else {
                return Observable.empty()
            }
            return reportUseCase.reportUser(userId: user.userId, type: reportType, content: currentState.content)
                .flatMap { _ in
                    return Observable.just(.setFinishedReport(true))
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
        case .setError(let error):
            newState.error = error
        case .setFinishedReport(let state):
            newState.finishedReport = state
        case .setContent(let content):
            newState.content = content
        case .setReportType(let type):
            newState.reportType = type
            newState.reportButtonEnable = type != nil ? true : false
        }
        return newState
    }
}
