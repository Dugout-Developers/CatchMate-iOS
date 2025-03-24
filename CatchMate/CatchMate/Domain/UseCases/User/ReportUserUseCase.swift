//
//  ReportUserUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 2/17/25.
//

import UIKit
import RxSwift

protocol ReportUserUseCase {
    func reportUser(userId: Int, type: ReportType, content: String) -> Observable<Void>
}

final class ReportUserUseCaseImpl: ReportUserUseCase {
    private let reportUserRepo: ReportUserRepository
    init(reportUserRepo: ReportUserRepository) {
        self.reportUserRepo = reportUserRepo
    }
    
    func reportUser(userId: Int, type: ReportType, content: String) -> Observable<Void> {
        return reportUserRepo.reportUser(userId: userId, type: type, content: content)
            .do(onNext: { _ in
                LoggerService.shared.log(level: .info, "\(userId)번 신고")
            })
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "유저 신고 실패")
                LoggerService.shared.errorLog(domainError, domain: "report_user", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
