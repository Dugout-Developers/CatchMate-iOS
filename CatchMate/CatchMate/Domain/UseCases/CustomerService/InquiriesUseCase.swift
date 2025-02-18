//
//  InquiriesUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 2/18/25.
//

import RxSwift

protocol InquiriesUseCase {
    func inquiry(type: CustomerServiceMenu, content: String) -> Observable<Void>
}

final class InquiriesUseCaseImpl: InquiriesUseCase {
    private let inquriesRepo: InquiriesRepository
    init(inquriesRepo: InquiriesRepository) {
        self.inquriesRepo = inquriesRepo
    }
    
    func inquiry(type: CustomerServiceMenu, content: String) -> Observable<Void> {
        return inquriesRepo.inquiry(type: type, content: content)
            .do(onNext: { _ in
                LoggerService.shared.log(level: .info, "문의하기 제출")
            })
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "문의를 보내는데 실패했어요")
                LoggerService.shared.errorLog(domainError, domain: "send_inquriy", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
