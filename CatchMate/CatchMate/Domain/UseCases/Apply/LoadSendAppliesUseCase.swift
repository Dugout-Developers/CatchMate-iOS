//
//  SendAppliesUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 9/5/24.
//

import UIKit
import RxSwift

/// 내가 보낸 신청 리스트 Load
protocol LoadSendAppliesUseCase {
    func execute() -> Observable<[ApplyList]>
}

final class LoadSendAppliesUseCaseImpl: LoadSendAppliesUseCase {
    private let sendAppliesRepository: SendAppiesRepository
    init(sendAppliesRepository: SendAppiesRepository) {
        self.sendAppliesRepository = sendAppliesRepository
    }
    func execute() -> RxSwift.Observable<[ApplyList]> {
        return sendAppliesRepository.loadSendApplies()
            .catch { error in
                return Observable.error(DomainError(error: error, context: .pageLoad))
            }
    }
}
