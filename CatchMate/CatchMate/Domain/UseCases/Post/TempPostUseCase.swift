//
//  TempPostUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 1/10/25.
//

import RxSwift

protocol TempPostUseCase {
    func execute(_ tempPost: TempPostRequest) -> Observable<Void>
}

final class TempPostUseCaseImpl: TempPostUseCase {
    private let tempPostRepository: TempPostRepository
    
    init(tempPostRepository: TempPostRepository) {
        self.tempPostRepository = tempPostRepository
    }
    
    func execute(_ tempPost: TempPostRequest) -> RxSwift.Observable<Void> {
        return tempPostRepository.tempPost(tempPost)
            .catch { error in
                return Observable.error(DomainError(error: error, context: .action, message: "게시글을 임시저장하는데 문제가 발생했습니다."))
            }
    }
}
