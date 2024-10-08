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
    func acceptApply(enrollId: String) -> Observable<Bool>
    func rejectApply(enrollId: String) -> Observable<Bool>
}

final class ReceivedAppliesUseCaseImpl: ReceivedAppliesUseCase {
    private let receivedAppliesRepository: RecivedAppiesRepository
    private let applyManagementRepository: ApplyManagementRepository
    init(receivedAppliesRepository: RecivedAppiesRepository, applyManagementRepository: ApplyManagementRepository) {
        self.receivedAppliesRepository = receivedAppliesRepository
        self.applyManagementRepository = applyManagementRepository
    }
    func loadRecivedApplies(boardId: Int) -> RxSwift.Observable<[RecivedApplyData]> {
        return receivedAppliesRepository.loadRecivedApplies(boardId: boardId)
    }
    
    func loadReceivedAppliesAll() -> RxSwift.Observable<[RecivedApplies]> {
        return receivedAppliesRepository.loadReceivedAppliesAll()
    }
    
    func acceptApply(enrollId: String) -> RxSwift.Observable<Bool> {
        return applyManagementRepository.acceptApply(enrollId: enrollId)
    }
    
    func rejectApply(enrollId: String) -> RxSwift.Observable<Bool> {
        return applyManagementRepository.rejectApply(enrollId: enrollId)
    }
}
