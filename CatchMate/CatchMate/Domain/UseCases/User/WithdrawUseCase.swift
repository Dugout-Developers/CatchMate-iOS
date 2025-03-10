//
//  WithdrawUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 3/6/25.
//

import RxSwift

protocol WithdrawUseCase {
    func withdraw() -> Observable<Void>
}

final class WithdrawUseCaseImpl: WithdrawUseCase {
    private let withdrawRepo: WithdrawRepository
    init(withdrawRepo: WithdrawRepository) {
        self.withdrawRepo = withdrawRepo
    }
    
    func withdraw() -> Observable<Void> {
        return withdrawRepo.withdraw()
            .do(onNext: { _ in
                LoggerService.shared.log(level: .info, "탈퇴하기")
            })
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "탈퇴에 실패했어요")
                LoggerService.shared.errorLog(domainError, domain: "withdraw", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
