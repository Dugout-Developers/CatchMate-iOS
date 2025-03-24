//
//  InquiriyDetailRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 3/20/25.
//

import RxSwift
import Foundation

final class InquiryDetailRepositoryImpl: InquiryDetailRepository {
    private let inquiryDS: InquiryDetailDataSource
    
    init(inquiryDS: InquiryDetailDataSource) {
        self.inquiryDS = inquiryDS
    }
    
    func getInquiryDetail(inquiryId: Int) -> RxSwift.Observable<Inquiry> {
        return inquiryDS.loadInquirity(id: inquiryId)
            .map { dto in
                let date = DateHelper.shared.convertISOStringToDate(dto.createdAt) ?? Date()
                let dateString = DateHelper.shared.toString(from: date, format: "yyyy년 M월 d일 hh")
                return Inquiry(id: dto.inquiryId, content: dto.content, nickName: dto.nickName, answer: dto.answer, createAt: dateString)
            }
    }
}
