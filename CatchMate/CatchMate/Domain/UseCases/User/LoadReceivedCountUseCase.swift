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
    /// 해당 에러는 페이지 로드에 큰 영향이 없으므로 loadPage지만 에러 로그만 남기고 표시하지 않는걸로 대체
    func execute() -> Observable<Int> {
        return loadCountRepository.loadCount()
            .catch { _ in
                return Observable.just(0)
            }
    }
}
