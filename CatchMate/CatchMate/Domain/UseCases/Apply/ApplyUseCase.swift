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
        return applyRepository.applyPost(postId, addInfo: addText ?? "")
            .catch { error in
                return Observable.error(DomainError(error: error, context: .action, message: "직관 신청하는데 문제가 발생했습니다."))
            }
    }
}


