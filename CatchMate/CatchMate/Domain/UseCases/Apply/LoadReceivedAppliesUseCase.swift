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
    func execute(boardId: Int) -> Observable<ReceivedAppliesList>
}

final class LoadReceivedAppliesUseCaseImpl: LoadReceivedAppliesUseCase {
    private let receivedAppliesRepository: RecivedAppiesRepository
    
    init(receivedAppliesRepository: RecivedAppiesRepository) {
        self.receivedAppliesRepository = receivedAppliesRepository
    }
    
    func execute(boardId: Int) -> RxSwift.Observable<ReceivedAppliesList> {
        LoggerService.shared.log(level: .info, "\(boardId)번 게시물 받은 신청 정보")
        return receivedAppliesRepository.loadRecivedApplies(boardId: boardId)
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "신청 정보를 불러오는데 문제가 발생했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "load_receivedapply_post", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
