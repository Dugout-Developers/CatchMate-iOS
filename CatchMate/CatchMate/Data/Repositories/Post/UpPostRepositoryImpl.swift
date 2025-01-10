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
    
    func upPost(_ postId: Int) -> RxSwift.Observable<Bool> {
        return upPostDS.upPost(postId)
    }
}
