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
            .catch { error in
                return Observable.error(DomainError(error: error, context: .action, message: "신청 정보를 불러오는데 문제가 발생했습니다."))
            }
    }
}
