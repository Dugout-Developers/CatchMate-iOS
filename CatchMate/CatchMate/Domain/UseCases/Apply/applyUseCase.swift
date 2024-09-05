//
//  applyUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 9/2/24.
//

import UIKit
import RxSwift

protocol applyUseCase {
    func applyPost(_ boardId: String, addInfo: String) -> Observable<MyApplyInfo>
    func isApply(boardId: Int) -> RxSwift.Observable<Bool>
}

final class applyUseCaseImpl: applyUseCase {
    private let applyRepository: ApplyRepository
    private let sendAppliesRepository: SendAppiesRepository
    
    init(applyRepository: ApplyRepository, sendAppliesRepository: SendAppiesRepository) {
        self.applyRepository = applyRepository
        self.sendAppliesRepository = sendAppliesRepository
    }
    
    func applyPost(_ boardId: String, addInfo: String) -> Observable<MyApplyInfo> {
        return applyRepository.applyPost(boardId, addInfo: addInfo)
            .map { result in
                return MyApplyInfo(enrollId: String(result), addInfo: addInfo)
            }
    }
    
    func isApply(boardId: Int) -> RxSwift.Observable<Bool> {
        return sendAppliesRepository.isApply(boardId: boardId)
    }
}
