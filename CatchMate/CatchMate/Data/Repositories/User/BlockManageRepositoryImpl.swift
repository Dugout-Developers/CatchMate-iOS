//
//  BlockManageRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 2/17/25.
//

import RxSwift

final class BlockManageRepositoryImpl: BlockManageRepository {
    private let blockManageDS: BlockManageDataSource
    init(blockManageDS: BlockManageDataSource) {
        self.blockManageDS = blockManageDS
    }
    
    func blockUser(_ userId: Int) -> RxSwift.Observable<Void> {
        return blockManageDS.blockUser(userId: userId)
            .flatMap { state in
                if state {
                    return Observable.just(())
                } else {
                    LoggerService.shared.log("Block Result False")
                    return Observable.error(MappingError.stateFalse)
                }
            }
    }
    
    func unblockUser(_ userId: Int) -> RxSwift.Observable<Void> {
        return blockManageDS.unblockUser(userId: userId)
            .flatMap { state in
                if state {
                    return Observable.just(())
                } else {
                    LoggerService.shared.log("Block Result False")
                    return Observable.error(MappingError.stateFalse)
                }
            }
    }
}
