//
//  AcceptApplyUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 12/17/24.
//

import UIKit
import RxSwift

/// 신청 수락 
protocol AcceptApplyUseCase {
    func execute(enrollId: String) -> Observable<Bool>
}

final class AcceptApplyUseCaseImpl: AcceptApplyUseCase {
    private let applyManagementRepository: ApplyManagementRepository
   
    init(applyManagementRepository: ApplyManagementRepository) {
        self.applyManagementRepository = applyManagementRepository
    }
    
    func execute(enrollId: String) -> Observable<Bool> {
        LoggerService.shared.log(level: .info, "신청 수락")
        return applyManagementRepository.acceptApply(enrollId: enrollId)
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "신청 처리 중 문제가 발생했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "accept_apply", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
