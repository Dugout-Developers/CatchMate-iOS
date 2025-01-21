//
//  UpPostRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 1/8/25.
//

import UIKit
import RxSwift

final class UpPostRepositoryImpl: UpPostRepository {
    private let upPostDS: UpPostDataSource
    init(upPostDS: UpPostDataSource) {
        self.upPostDS = upPostDS
    }
    
    func upPost(_ postId: String) -> RxSwift.Observable<(result: Bool, message: String?)> {
        guard let postId = Int(postId) else {
            return Observable.error(MappingError.mappingFailed)
        }
        return upPostDS.upPost(postId)
            .map { dto in
                return (dto.state, dto.remainTime)
            }
    }
}
