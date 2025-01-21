//
//  rejectApplyUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 12/17/24.
//

import UIKit
import RxSwift

/// 신청 거절
protocol RejectApplyUseCase {
    func execute(enrollId: String) -> Observable<Bool>
}

final class RejectApplyUseCaseImpl: RejectApplyUseCase {
    private let applyManagementRepository: ApplyManagementRepository
   
    init(applyManagementRepository: ApplyManagementRepository) {
        self.applyManagementRepository = applyManagementRepository
    }
    
    func execute(enrollId: String) -> Observable<Bool> {
        return applyManagementRepository.rejectApply(enrollId: enrollId)
            .catch { error in
                return Observable.error(DomainError(error: error, context: .action, message: "거절하는데 문제가 발생했습니다."))
            }
    }
}
