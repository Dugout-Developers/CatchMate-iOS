//
//  InquiryReactor.swift
//  CatchMate
//
//  Created by 방유빈 on 3/19/25.
//

import UIKit
import RxSwift
import ReactorKit

final class InquiryReactor: Reactor {
    enum Action {
        case loadInquiryDetail
    }
    enum Mutation {
        case setInquiryDetail(Inquiry)
        case serError(PresentationError?)
    }
    struct State {
        var inquiryDetail: Inquiry?
        var error: PresentationError?
    }
    
    var initialState: State
    private let inquiryId: Int
    private let inquiryUsecase: InquiryDetailUseCase
    init(inquiryId: Int, inquiryUsecase: InquiryDetailUseCase) {
        self.inquiryId = inquiryId
        self.inquiryUsecase = inquiryUsecase
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadInquiryDetail:
            return inquiryUsecase.getInquiriyDetail(inquiriyId: inquiryId)
                .flatMap { inquiry in
                    return Observable.just(.setInquiryDetail(inquiry))
                }
                .catch { error in
                    return Observable.just(.serError(ErrorMapper.mapToPresentationError(error)))
                }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setInquiryDetail(let detail):
            newState.inquiryDetail = detail
        case .serError(let error):
            newState.error = error
        }
        return newState
    }
}
