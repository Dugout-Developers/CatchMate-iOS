//
//  CancelApplyUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 12/17/24.
//

/// 신청 취소
protocol CancelApplyUseCase {
    func excute(enrollId: String) -> Observable<Void>
}
final class CancelApplyUseCaseImpl: CancelApplyUseCase {
    private let applyRepository: ApplyRepository
    init(applyRepository: ApplyRepository) {
        self.applyRepository = applyRepository
    }
    
    func excute(enrollId: String) -> Observable<Void> {
        return applyRepository.cancelApplyPost(enrollId: enrollId)
    }
}
