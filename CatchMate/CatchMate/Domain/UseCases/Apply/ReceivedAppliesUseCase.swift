//
//  ReceivedAppliesUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 9/10/24.
//

import UIKit
import RxSwift

protocol ReceivedAppliesUseCase {
    func loadRecivedApplies(boardId: Int) -> Observable<[RecivedApplyData]>
    func loadReceivedAppliesAll() -> Observable<[RecivedApplies]>
}

final class ReceivedAppliesUseCaseImpl: ReceivedAppliesUseCase {
    private let receivedAppliesRepository: RecivedAppiesRepository
    init(receivedAppliesRepository: RecivedAppiesRepository) {
        self.receivedAppliesRepository = receivedAppliesRepository
    }
    func loadRecivedApplies(boardId: Int) -> RxSwift.Observable<[RecivedApplyData]> {
        return receivedAppliesRepository.loadRecivedApplies(boardId: boardId)
    }
    
    func loadReceivedAppliesAll() -> RxSwift.Observable<[RecivedApplies]> {
        return receivedAppliesRepository.loadReceivedAppliesAll()
    }
}
