//
//  RecivedAppliesRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 9/30/24.
//

import UIKit
import RxSwift

final class RecivedAppliesRepositoryImpl: RecivedAppiesRepository {
    private let recivedAppliesDS: RecivedAppiesDataSource
    init(recivedAppliesDS: RecivedAppiesDataSource) {
        self.recivedAppliesDS = recivedAppliesDS
    }
    
    func loadRecivedApplies(boardId: Int, page: Int) -> RxSwift.Observable<ReceivedAppliesList> {
        return recivedAppliesDS.loadRecivedApplies(boardId: boardId, page: page)
            .map { dto in
                let mapper = ApplyMapper()
                var mappingList = [RecivedApplies]()
                dto.enrollInfoList.forEach { info in
                    if let mappingResult = mapper.receivedApplyMapping(info) {
                        mappingList.append(mappingResult)
                    }
                }
                return ReceivedAppliesList(applies: mappingList, isLast: dto.isLast)
            }
    }
    
    func loadReceivedAppliesAll(_ page: Int) -> RxSwift.Observable<ReceivedAppliesList> {
        return recivedAppliesDS.loadReceivedAppliesAll(page)
            .map { dto in
                let mapper = ApplyMapper()
                var mappingList = [RecivedApplies]()
                dto.enrollInfoList.forEach { info in
                    if let mappingResult = mapper.receivedApplyMapping(info) {
                        mappingList.append(mappingResult)
                    }
                }
                return ReceivedAppliesList(applies: mappingList, isLast: dto.isLast)
            }
    }

}

