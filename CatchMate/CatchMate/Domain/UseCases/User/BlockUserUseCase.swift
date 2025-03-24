//
//  BlockUserUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 2/17/25.
//
import RxSwift

protocol BlockUserUseCase {
    func blockUser(_ userId: Int) -> Observable<Void>
}

final class BlockUserUseCaseImpl: BlockUserUseCase {
    private let blockManageRepo: BlockManageRepository
    init(blockManageRepo: BlockManageRepository) {
        self.blockManageRepo = blockManageRepo
    }
    
    func blockUser(_ userId: Int) -> Observable<Void> {
        return blockManageRepo.blockUser(userId)
            .do(onNext: { _ in
                LoggerService.shared.log(level: .info, "\(userId)번 치단")
            })
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "차단에 실패했어요")
                LoggerService.shared.errorLog(domainError, domain: "block_user", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
