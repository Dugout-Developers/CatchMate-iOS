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
        // 사용자의 입력과 상호작용하는 역할을 한다
        case willAppear
    }
    enum Mutation {
        // Action과 State 사이의 다리역할이다.
        // action stream을 변환하여 state에 전달한다.
        case loadPost
    }
    struct State {
        // View의 state를 관리한다.
        
        var error: Error?
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
    }
}
