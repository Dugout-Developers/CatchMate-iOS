//
//  InquiriesRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 2/18/25.
//

import RxSwift

final class InquiriesRepositoryImpl: InquiriesRepository {
    private let inquriesDS: InquiriesDataSource
    init(inquriesDS: InquiriesDataSource) {
        self.inquriesDS = inquriesDS
    }
    
    func inquiry(type: CustomerServiceMenu, content: String) -> RxSwift.Observable<Void> {
        return inquriesDS.sendInquiry(type: type.serverRequest, content: content)
            .flatMap { state in
                if state {
                    return Observable.just(())
                } else {
                    LoggerService.shared.log("Inquiry Result False")
                    return Observable.error(MappingError.stateFalse)
                }
            }
    }

}
