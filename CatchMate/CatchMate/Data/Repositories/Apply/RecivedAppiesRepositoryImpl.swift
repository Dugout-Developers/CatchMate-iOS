//
//  RecivedAppiesRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 9/5/24.
//

import UIKit
import RxSwift

final class RecivedAppiesRepositoryImpl: RecivedAppiesRepository {
    private let recivedAppiesDS: RecivedAppiesDataSource
    init(recivedAppiesDS: RecivedAppiesDataSource) {
        self.recivedAppiesDS = recivedAppiesDS
    }
    func loadRecivedApplies(boardId: Int) -> RxSwift.Observable<[ApplyList]> {
        return recivedAppiesDS.loadRecivedApplies(boardId: boardId)
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
            .catch { error in
                return Observable.error(ErrorMapper.mapToPresentationError(error))
            }
    }
}
