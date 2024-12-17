//
//  ReceivedAppliesUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 9/10/24.
//

import UIKit
import RxSwift

/// 게시물 1개에 관해 받은신청 정보 Load
protocol LoadReceivedAppliesUseCase {
    func execute(boardId: Int) -> Observable<[RecivedApplyData]>
}

final class LoadReceivedAppliesUseCaseImpl: LoadReceivedAppliesUseCase {
    private let receivedAppliesRepository: RecivedAppiesRepository
    
    init(receivedAppliesRepository: RecivedAppiesRepository) {
        self.receivedAppliesRepository = receivedAppliesRepository
    }
    
    func execute(boardId: Int) -> RxSwift.Observable<[RecivedApplyData]> {
        return receivedAppliesRepository.loadRecivedApplies(boardId: boardId)
    }
}
