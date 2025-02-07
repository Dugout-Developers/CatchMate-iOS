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
    
    func loadReceivedAppliesAll() -> RxSwift.Observable<[RecivedApplies]> {
        return recivedAppliesDS.loadReceivedAppliesAll()
            .flatMap { contents -> Observable<[RecivedApplies]> in
                let mapper = ApplyMapper()
                var mappingList = [RecivedApplies]()
                contents.forEach { content in
                    if let result = mapper.dtoToDomain(content) {
                        let postId = result.post.id
                        let apply = RecivedApplyData(enrollId: result.enrollId, user: result.user, addText: result.addText, new: result.new)
                        if let index = mappingList.firstIndex(where: { $0.post.id == postId}) {
                            mappingList[index].appendApply(apply: apply)
                        } else {
                            mappingList.append(RecivedApplies(post: result.post, applies: [apply]))
                        }
                    } else {
                        LoggerService.shared.log("Repository 매핑 에러 - postId:\(content.boardInfo.boardId) / enrollId: \(content.enrollId)")
                    }
                }
                return Observable.just(mappingList.sorted(by: <))
            }
    }

}

