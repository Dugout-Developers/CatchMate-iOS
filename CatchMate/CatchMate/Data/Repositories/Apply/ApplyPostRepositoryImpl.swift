//
//  ApplyPostRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 9/2/24.
//

import UIKit
import RxSwift

final class ApplyPostRepositoryImpl: ApplyRepository {
    private let applyDS: ApplyDataSource
    
    init(applyDS: ApplyDataSource) {
        self.applyDS = applyDS
    }
    
    func applyPost(_ boardId: String, addInfo: String) -> Observable<Int> {
        return applyDS.applyPost(boardID: boardId, addInfo: addInfo)
            .catch { error in
                return Observable.error(ErrorMapper.mapToPresentationError(error))
            }
    }
}
