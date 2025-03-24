//
//  ApplyHandleUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 9/5/24.
//

import UIKit
import RxSwift

/// 신청하기
protocol ApplyUseCase {
    func execute(postId: String, addText: String?) -> Observable<Int>
}
final class ApplyUseCaseImpl: ApplyUseCase {
    private let applyRepository: ApplyRepository
    init(applyRepository: ApplyRepository) {
        self.applyRepository = applyRepository
    }
    
    func execute(postId: String, addText: String?) -> Observable<Int> {
        LoggerService.shared.log(level: .info, "\(postId)게시물 직관 신청")
        return applyRepository.applyPost(postId, addInfo: addText ?? "")
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "직관 신청하는 중 문제가 발생했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "apply", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}


