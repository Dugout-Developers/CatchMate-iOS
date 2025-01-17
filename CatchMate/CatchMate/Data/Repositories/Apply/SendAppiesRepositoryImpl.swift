//
//  SendAppiesRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 9/5/24.
//

import UIKit
import RxSwift

final class SendAppiesRepositoryImpl: SendAppiesRepository {
    private let sendAppliesDS: SendAppiesDataSource
    init(sendAppliesDS: SendAppiesDataSource) {
        self.sendAppliesDS = sendAppliesDS
    }
    func loadSendApplies() -> RxSwift.Observable<[ApplyList]> {
        return sendAppliesDS.loadSendApplies()
            .flatMap { contents -> Observable<[ApplyList]> in
                let mapper = ApplyMapper()
                var mappingList = [ApplyList]()
                contents.forEach { content in
                    if let result = mapper.dtoToDomain(content) {
                        mappingList.append(result)
                    }
                }
                return Observable.just(mappingList)
            }
    }
    
    func isApply(boardId: Int) -> RxSwift.Observable<Bool> {
        return sendAppliesDS.loadSendApplyBoardIds()
            .flatMap { list -> Observable<Bool> in
                return Observable.just(list.contains(boardId))
            }
    }
    
    
}
