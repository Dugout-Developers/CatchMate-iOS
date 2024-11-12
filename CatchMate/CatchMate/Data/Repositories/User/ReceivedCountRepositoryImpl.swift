//
//  ReceivedCountRepositoryIml.swift
//  CatchMate
//
//  Created by 방유빈 on 11/13/24.
//

import UIKit
import RxSwift

final class ReceivedCountRepositoryIml: ReceivedCountRepository {
    private let loadCountDS: ReceivedCountDataSource
    
    init(loadCountDS: ReceivedCountDataSource) {
        self.loadCountDS = loadCountDS
    }
    
    func loadCount() -> RxSwift.Observable<Int> {
        return loadCountDS.getReceivedCount()
            .map { dto -> Int in
                return dto.newEnrollListCount
            }
            .catch { error in
                return Observable.error(ErrorMapper.mapToPresentationError(error))
            }
    }
}
