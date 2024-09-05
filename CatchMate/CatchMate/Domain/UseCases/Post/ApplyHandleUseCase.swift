//
//  ApplyHandleUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 9/5/24.
//

import UIKit
import RxSwift

protocol ApplyHandleUseCase {
    func apply(postId: String, addText: String?) -> Observable<Int>
    func cancelApplyPost(enrollId: String) -> Observable<Bool>
}
final class ApplyHandleUseCaseImpl: ApplyHandleUseCase {
    private let applyRepository: ApplyRepository
    init(applyRepository: ApplyRepository) {

        self.applyRepository = applyRepository
    }
    
    func apply(postId: String, addText: String?) -> Observable<Int> {
        return applyRepository.applyPost(postId, addInfo: addText ?? "")
    }
    
    func cancelApplyPost(enrollId: String) -> Observable<Bool> {
        return applyRepository.cancelApplyPost(enrollId: enrollId)
    }
}
