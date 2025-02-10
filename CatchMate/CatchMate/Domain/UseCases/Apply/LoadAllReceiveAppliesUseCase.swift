//
//  LoadAllReceiveAppliesUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 12/17/24.
//

import UIKit
import RxSwift

/// 모든 게시물 받은 신청 정보 Load
protocol LoadAllReceiveAppliesUseCase {
    func execute() -> Observable<ReceivedAppliesList>
}

final class LoadAllReceiveAppliesUseCaseImpl: LoadAllReceiveAppliesUseCase {
    private let receivedAppliesRepository: RecivedAppiesRepository
   
    init(recivedAppliesRepository: RecivedAppiesRepository) {
        self.receivedAppliesRepository = recivedAppliesRepository
    }
    
    func execute() -> Observable<ReceivedAppliesList> {
        LoggerService.shared.log(level: .info, "모든 게시물 받은 신청 정보")
        return receivedAppliesRepository.loadReceivedAppliesAll()
            .catch { error in
                let domainError = DomainError(error: error, context: .pageLoad)
                LoggerService.shared.errorLog(domainError, domain: "load_receivedapply_all", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
