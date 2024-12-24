//
//  ApplyManageUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 12/17/24.
//
import UIKit
import RxSwift

enum ApplyManageType {
    case accept
    case reject
}
/// 신청관리 -> 신청 수락, 거절 상위 UseCase
protocol ApplyManageUseCase {
    func execute(type: ApplyManageType, enrollId: String) -> Observable<Bool>
}

final class ApplyManageUseCaseImpl: ApplyManageUseCase {
    private let acceptApplyUseCase: AcceptApplyUseCase
    private let rejectApplyUseCase: RejectApplyUseCase
    
    init(acceptApplyUseCase: AcceptApplyUseCase, rejectApplyUseCase: RejectApplyUseCase) {
        self.acceptApplyUseCase = acceptApplyUseCase
        self.rejectApplyUseCase = rejectApplyUseCase
    }
    
    func execute(type: ApplyManageType, enrollId: String) -> RxSwift.Observable<Bool> {
        switch type {
        case .accept:
            return acceptApplyUseCase.execute(enrollId: enrollId)
        case .reject:
            return rejectApplyUseCase.execute(enrollId: enrollId)
        }
    }
    
}
