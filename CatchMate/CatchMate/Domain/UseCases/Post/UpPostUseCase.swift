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
        guard let id = Int(postId) else {
            return Observable.error(PresentationError.showToastMessage(message: "게시글 끌어올리기를 실패했습니다."))
        }
        return upPostRepository.upPost(id)
            .catch { error in
                return Observable.error(DomainError(error: error, context: .action, message: "게시글 끌어올리기를 실패했습니다."))
            }
    }
}
