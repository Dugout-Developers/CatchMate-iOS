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
    func loadSendApplies(page: Int) -> RxSwift.Observable<Applys> {
        return sendAppliesDS.loadSendApplies(page: page)
            .flatMap { applyInfo -> Observable<Applys> in
                let mapper = ApplyMapper()
                var mappingList = [ApplyList]()
                applyInfo.enrollInfoList.forEach { content in
                    if let result = mapper.dtoToDomain(content) {
                        mappingList.append(result)
                    } else {
                        LoggerService.shared.log("\(content.enrollId) 매핑 실패")
                    }
                }
                return Observable.just(Applys(applys: mappingList, isLast: applyInfo.isLast))
            }
    }
    
    func loadSendApplyDetail(_ boardId: Int) -> RxSwift.Observable<MyApplyInfo> {
        return sendAppliesDS.loadSendApplyDetail(boardId)
            .map { dto in
                return MyApplyInfo(enrollId: dto.enrollId, addInfo: dto.description)
            }
    }
}
