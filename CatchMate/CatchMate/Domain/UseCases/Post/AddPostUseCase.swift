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
        LoggerService.shared.log(level: .info, "게시물 작성")
        return addPostRepository.addPost(post)
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "게시물 저장에 실패했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "add_post", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
    
    func editPost(_ post: RequestEditPost, boardId: Int) -> Observable<Int> {
        LoggerService.shared.log(level: .info, "게시물 수정")
        return addPostRepository.editPost(post, boardId: boardId)
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "게시물 수정에 실패했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "edit_post", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
    func addTempPost(post: RequestPost, boardId: String) -> RxSwift.Observable<Int> {
        LoggerService.shared.log(level: .info, "게시물 임시 저장")
        return addPostRepository.addTempPost(post, boardId: boardId)
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "임시저장에 실패했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "temp_post", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
    
}

