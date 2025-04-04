//
//  CancelApplyUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 12/17/24.
//

import UIKit
import RxSwift

/// 신청 취소
protocol CancelApplyUseCase {
    func execute(enrollId: String) -> Observable<Void>
}
final class CancelApplyUseCaseImpl: CancelApplyUseCase {
    private let applyRepository: ApplyRepository
    init(applyRepository: ApplyRepository) {
        self.applyRepository = applyRepository
    }
    
    func execute(enrollId: String) -> Observable<Void> {
        LoggerService.shared.log(level: .info, "보낸 신청 취소")
        return applyRepository.cancelApplyPost(enrollId: enrollId)
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "취소 중 문제가 발생했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "cancel_apply", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
