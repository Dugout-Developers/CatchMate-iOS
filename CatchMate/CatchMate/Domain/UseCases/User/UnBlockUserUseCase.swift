//
//  UnBlockUserUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 2/17/25.
//

import RxSwift

protocol UnBlockUserUseCase {
    func unblockUser(_ userId: Int) -> Observable<Void>
}

final class UnBlockUserUseCaseImpl: UnBlockUserUseCase {
    private let blockManageRepo: BlockManageRepository
    init(blockManageRepo: BlockManageRepository) {
        self.blockManageRepo = blockManageRepo
    }
    
    func unblockUser(_ userId: Int) -> Observable<Void> {
        return blockManageRepo.unblockUser(userId)
            .do(onNext: { _ in
                LoggerService.shared.log(level: .info, "\(userId)번 차단해제")
            })
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "차단 해제에 실패했어요")
                LoggerService.shared.errorLog(domainError, domain: "unblock_user", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
