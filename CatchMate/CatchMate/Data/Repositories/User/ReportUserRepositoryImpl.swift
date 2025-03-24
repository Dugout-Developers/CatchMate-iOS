//
//  ReportUserRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 2/17/25.
//

import UIKit
import RxSwift

final class ReportUserRepositoryImpl: ReportUserRepository {
    private let reportUserDS: ReportUserDataSource
    init(reportUserDS: ReportUserDataSource) {
        self.reportUserDS = reportUserDS
    }
    
    func reportUser(userId: Int, type: ReportType, content: String) -> RxSwift.Observable<Void> {
        let reportInfo = ReportUserDTO(reportType: type.servserRequest, content: content)
        return reportUserDS.reportUser(reportInfo: reportInfo, userId: userId)
            .flatMap { state in
                if state {
                    return Observable.just(())
                } else {
                    return Observable.error(MappingError.stateFalse)
                }
            }
    }
}
