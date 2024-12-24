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
    // 게시글 수정 필요
}

final class DeletePostUseCaseImpl: DeletePostUseCase {
    private let deleteRepository: DeletePostRepository
    init(deleteRepository: DeletePostRepository) {
        self.deleteRepository = deleteRepository
    }
    
    func deletePost(postId: Int) -> RxSwift.Observable<Void> {
        return deleteRepository.deletePost(postId: postId)
    }
}
