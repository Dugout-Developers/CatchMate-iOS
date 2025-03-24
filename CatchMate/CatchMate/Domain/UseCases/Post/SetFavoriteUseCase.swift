//
//  SetFavoriteUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 9/1/24.
//

import UIKit
import RxSwift

protocol SetFavoriteUseCase {
    func execute(_ state: Bool, _ boardId: String) -> Observable<Bool>
}

final class SetFavoriteUseCaseImpl: SetFavoriteUseCase {
    private let setFavoriteRepository: SetFavoriteRepository
    
    init(setFavoriteRepository: SetFavoriteRepository) {
        self.setFavoriteRepository = setFavoriteRepository
    }
    
    func execute(_ state: Bool, _ boardId: String) -> Observable<Bool> {
        return setFavoriteRepository.setFavorite(state, boardId)
            .catch { error in
                if state {
                    LoggerService.shared.log(level: .info, "\(boardId)번 찜하기")
                    let domainError = DomainError(error: error, context: .action, message: "찜하기 과정에서 문제가 발생했습니다.")
                    LoggerService.shared.errorLog(domainError, domain: "set_favorite", message: error.errorDescription)
                    return Observable.error(domainError)
                } else {
                    LoggerService.shared.log(level: .info, "\(boardId)번 찜삭제")
                    let domainError = DomainError(error: error, context: .action, message: "찜하기 과정에서 문제가 발생했습니다.")
                    LoggerService.shared.errorLog(domainError, domain: "cancel_favorite", message: error.errorDescription)
                    return Observable.error(domainError)
                }
            }
    }
}
