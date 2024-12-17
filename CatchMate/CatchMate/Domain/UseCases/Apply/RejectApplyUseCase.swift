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
    }
}
