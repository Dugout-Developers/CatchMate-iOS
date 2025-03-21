//
//  InquiriyDetailUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 3/20/25.
//

import RxSwift

protocol InquiryDetailUseCase {
    func getInquiriyDetail(inquiriyId: Int) -> Observable<Inquiry>
}

final class InquiryDetailUseCaseImpl: InquiryDetailUseCase {
    private let inquiryRepository: InquiryDetailRepository
    
    init(inquiryRepository: InquiryDetailRepository) {
        self.inquiryRepository = inquiryRepository
    }
    func getInquiriyDetail(inquiriyId: Int) -> RxSwift.Observable<Inquiry> {
        return inquiryRepository.getInquiryDetail(inquiryId: inquiriyId)
            .do(onNext: { _ in
                LoggerService.shared.log(level: .info, "\(inquiriyId)번 공지사항 답변 불러오기)")
            })
            .catch { error in
                let domainError = DomainError(error: error, context: .pageLoad, message: "문의 사항을 불러오는데 실패했어요")
                LoggerService.shared.errorLog(domainError, domain: "load_inquiry", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
    
}
