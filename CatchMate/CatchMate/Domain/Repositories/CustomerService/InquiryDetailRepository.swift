//
//  InquiriyDetailRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 3/20/25.
//

import RxSwift

protocol InquiryDetailRepository {
    func getInquiryDetail(inquiryId: Int) -> Observable<Inquiry>
}
