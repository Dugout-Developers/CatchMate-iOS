//
//  applyUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 9/2/24.
//

import UIKit
import RxSwift

protocol applyUseCase {
    func applyPost(_ boardId: String, addInfo: String) -> Observable<MyApplyInfo>
}

final class applyUseCaseImpl: applyUseCase {
    private let applyRepository: ApplyRepository
    
    init(applyRepository: ApplyRepository) {
        self.applyRepository = applyRepository
    }
    
    func applyPost(_ boardId: String, addInfo: String) -> Observable<MyApplyInfo> {
        return applyRepository.applyPost(boardId, addInfo: addInfo)
            .map { result in
                return MyApplyInfo(enrollId: String(result), addInfo: addInfo)
            }
    }
}
