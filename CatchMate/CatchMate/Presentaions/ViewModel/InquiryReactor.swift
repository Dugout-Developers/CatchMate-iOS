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
    private var inquiryId: Int
    init(inquiryId: Int) {
        self.inquiryId = inquiryId
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadInquiryDetail:
            return Observable.just(.setInquiryDetail(Inquiry(id: 1,
                                                             content: "ㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\n",
                                                             nickName: "방가방가 해ㅔㅁ토리",
                                                             answer: "ㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\nㅇㅁㄴ라ㅓㅁ나ㅣ러ㅏㅣㅁ넝리ㅏㅓㅁ닝러ㅣㅏ\n",
                                                             createAt: "2025-03-22")))
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
