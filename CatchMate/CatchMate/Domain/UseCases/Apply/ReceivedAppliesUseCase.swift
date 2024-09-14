//
//  ReceivedAppliesUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 9/10/24.
//

import UIKit
import RxSwift

protocol ReceivedAppliesUseCase {
    func loadRecivedApplies(boardId: Int) -> Observable<[ApplyList]>
    func loadReceivedAppliesAll() -> Observable<[String: [ApplyList]]>
}

final class ReceivedAppliesUseCaseImpl: ReceivedAppliesUseCase {
    private let receivedAppliesRepository: RecivedAppiesRepository
    init(receivedAppliesRepository: RecivedAppiesRepository) {
        self.receivedAppliesRepository = receivedAppliesRepository
    }
    func loadRecivedApplies(boardId: Int) -> RxSwift.Observable<[ApplyList]> {
        return receivedAppliesRepository.loadRecivedApplies(boardId: boardId)
    }
    
    func loadReceivedAppliesAll() -> RxSwift.Observable<[String : [ApplyList]]> {
        return receivedAppliesRepository.loadReceivedAppliesAll()
    }
}
