//
//  UpPostUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 1/8/25.
//

import UIKit
import RxSwift

protocol UpPostUseCase {
    func execute(_ postId: String) -> Observable<(result: Bool, message: String?)>
}

final class UpPostUseCaseImpl: UpPostUseCase {
    private let upPostRepository: UpPostRepository
    init(upPostRepository: UpPostRepository) {
        self.upPostRepository = upPostRepository
    }
    
    func execute(_ postId: String) -> Observable<(result: Bool, message: String?)> {
        LoggerService.shared.log(level: .info, "\(postId)번 게시물 끌어올리기")
        return upPostRepository.upPost(postId)
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "게시글 끌어올리는데 문제가 발생했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "up_post", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
