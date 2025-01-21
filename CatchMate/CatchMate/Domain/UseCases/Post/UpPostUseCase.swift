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
        return upPostRepository.upPost(postId)
            .catch { error in
                return Observable.error(DomainError(error: error, context: .action, message: "게시글 끌어올리는데 문제가 발생했습니다."))
            }
    }
}
