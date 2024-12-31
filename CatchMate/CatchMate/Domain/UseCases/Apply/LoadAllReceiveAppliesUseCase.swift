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
    func execute() -> Observable<[RecivedApplies]>
}

final class LoadAllReceiveAppliesUseCaseImpl: LoadAllReceiveAppliesUseCase {
    private let receivedAppliesRepository: RecivedAppiesRepository
   
    init(recivedAppliesRepository: RecivedAppiesRepository) {
        self.receivedAppliesRepository = recivedAppliesRepository
    }
    
    func execute() -> Observable<[RecivedApplies]> {
        return receivedAppliesRepository.loadReceivedAppliesAll()
            .catch { error in
                return Observable.error(DomainError(error: error, context: .pageLoad).toPresentationError())
            }
    }
}
