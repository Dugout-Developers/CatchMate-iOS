//
//  DeletePostRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 9/27/24.
//

import UIKit
import RxSwift

final class DeletePostRepositoryImpl: DeletePostRepository {
    private let deletePostDS: DeletePostDataSource
    init(deletePostDS: DeletePostDataSource) {
        self.deletePostDS = deletePostDS
    }
    
    func deletePost(postId: Int) -> RxSwift.Observable<Void> {
        return deletePostDS.deletePost(postId: postId)
    }
}
