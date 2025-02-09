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
    
    func loadRecivedApplies(boardId: Int) -> RxSwift.Observable<[RecivedApplyData]> {
        return recivedAppliesDS.loadRecivedApplies(boardId: boardId)
            .flatMap { contents -> Observable<[RecivedApplyData]> in
                let mapper = ApplyMapper()
                var mappingList = [RecivedApplyData]()
                contents.forEach { content in
                    if let result = mapper.dtoToDomain(content) {
                        mappingList.append(RecivedApplyData(enrollId: result.enrollId, user: result.user, addText: result.addText, new: result.new))
                    } else {
                        LoggerService.shared.log("\(content.enrollId) 매핑 실패")
                    }
                }
                return Observable.just(mappingList)
            }
    }
    
    func loadReceivedAppliesAll() -> RxSwift.Observable<ReceivedAppliesList> {
        return recivedAppliesDS.loadReceivedAppliesAll()
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

