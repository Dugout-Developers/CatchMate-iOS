//
//  WithdrawRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 3/6/25.
//

import RxSwift

final class WithdrawRepositoryImp: WithdrawRepository {
    private let withdrawDS: WithdrawDataSource
    init(withdrawDS: WithdrawDataSource) {
        self.withdrawDS = withdrawDS
    }
    
    func withdraw() -> RxSwift.Observable<Void> {
        return withdrawDS.withdraw()
            .flatMap { state in
                if state {
                    return Observable.just(())
                } else {
                    return Observable.error(MappingError.stateFalse)
                }
            }
    }
}
