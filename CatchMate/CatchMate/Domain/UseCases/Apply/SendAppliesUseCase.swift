//
//  SendAppliesUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 9/5/24.
//

import UIKit
import RxSwift

protocol SendAppliesUseCase {
    func loadSendApplies() -> Observable<[ApplyList]>
    func isApply(boardId: Int) -> Observable<Bool>
}

final class SendAppliesUseCaseImpl: SendAppliesUseCase {
    private let sendAppliesRepository: SendAppiesRepository
    init(sendAppliesRepository: SendAppiesRepository) {
        self.sendAppliesRepository = sendAppliesRepository
    }
    func loadSendApplies() -> RxSwift.Observable<[ApplyList]> {
        return sendAppliesRepository.loadSendApplies()
    }
    
    func isApply(boardId: Int) -> RxSwift.Observable<Bool> {
        return sendAppliesRepository.isApply(boardId: boardId)
    }
}
