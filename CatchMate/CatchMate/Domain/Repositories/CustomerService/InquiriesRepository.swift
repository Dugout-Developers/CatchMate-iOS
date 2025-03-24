//
//  InquiriesRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 2/18/25.
//

import RxSwift

protocol InquiriesRepository {
    func inquiry(type: CustomerServiceMenu, content: String) -> Observable<Void>
}
