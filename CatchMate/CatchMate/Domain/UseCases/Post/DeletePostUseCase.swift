//
//  PostHandleUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 9/27/24.
//

import UIKit
import RxSwift

protocol DeletePostUseCase {
    func deletePost(postId: Int) -> Observable<Void>
}

final class DeletePostUseCaseImpl: DeletePostUseCase {
    private let deleteRepository: DeletePostRepository
    init(deleteRepository: DeletePostRepository) {
        self.deleteRepository = deleteRepository
    }
    
    func deletePost(postId: Int) -> RxSwift.Observable<Void> {
        return deleteRepository.deletePost(postId: postId)
            .catch { error in
                return Observable.error(DomainError(error: error, context: .action, message: "게시물 삭제에 실패했습니다."))
            }
    }
}
