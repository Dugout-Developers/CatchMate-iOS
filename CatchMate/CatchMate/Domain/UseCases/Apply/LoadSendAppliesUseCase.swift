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
    func execute(page: Int) -> Observable<Applys>
}

final class LoadSendAppliesUseCaseImpl: LoadSendAppliesUseCase {
    private let sendAppliesRepository: SendAppiesRepository
    init(sendAppliesRepository: SendAppiesRepository) {
        self.sendAppliesRepository = sendAppliesRepository
    }
    func execute(page: Int) -> RxSwift.Observable<Applys> {
        return sendAppliesRepository.loadSendApplies(page: page)
            .catch { error in
                return Observable.error(DomainError(error: error, context: .pageLoad))
            }
    }
}
