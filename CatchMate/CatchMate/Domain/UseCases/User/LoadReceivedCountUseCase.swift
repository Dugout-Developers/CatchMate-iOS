//
//  LoadReceivedCountUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 12/17/24.
//

import UIKit
import RxSwift

protocol LoadReceivedCountUseCase {
    func execute() -> Observable<Int>
}

final class LoadReceivedCountUseCaseImpl: LoadReceivedCountUseCase {
    private let loadCountRepository: ReceivedCountRepository

    init(loadCountRepository: ReceivedCountRepository) {
        self.loadCountRepository = loadCountRepository
    }
    func execute() -> Observable<Int> {
        return loadCountRepository.loadCount()
    }
}
