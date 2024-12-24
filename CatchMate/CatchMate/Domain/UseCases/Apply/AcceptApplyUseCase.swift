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
        return applyManagementRepository.acceptApply(enrollId: enrollId)
    }
}
