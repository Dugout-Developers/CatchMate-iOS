//
//  AddPostUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//

import UIKit
import RxSwift

protocol AddPostUseCase {
    func addPost(_ post: RequestPost) -> Observable<Int>
    func editPost(_ post: RequestEditPost, boardId: Int) -> Observable<Int>
    func addTempPost(post: RequestPost, boardId: String) -> Observable<Int>
}

final class AddPostUseCaseImpl: AddPostUseCase {
    private let addPostRepository: AddPostRepository
    
    init(addPostRepository: AddPostRepository) {
        self.addPostRepository = addPostRepository
    }
    
    func addPost(_ post: RequestPost) -> Observable<Int> {
        return addPostRepository.addPost(post)
            .catch { error in
                return Observable.error(DomainError(error: error, context: .action))
            }
    }
    
    func editPost(_ post: RequestEditPost, boardId: Int) -> Observable<Int> {
        return addPostRepository.editPost(post, boardId: boardId)
            .catch { error in
                return Observable.error(DomainError(error: error, context: .action, message: "요청에 실패했습니다.").toPresentationError())
            }
    }
    func addTempPost(post: RequestPost, boardId: String) -> RxSwift.Observable<Int> {
        return addPostRepository.addTempPost(post, boardId: boardId)
            .catch { error in
                return Observable.error(DomainError(error: error, context: .action, message: "요청에 실패했습니다.").toPresentationError())
            }
    }
    
}

