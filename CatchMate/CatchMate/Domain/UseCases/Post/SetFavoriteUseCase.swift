//
//  SetFavoriteUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 9/1/24.
//

import UIKit
import RxSwift

protocol SetFavoriteUseCase {
    func setFavorite(_ state: Bool, _ boardId: String) -> Observable<Bool>
    func syncWithLocalDatabase(_ state: Bool, _ boardId: String)
}

final class SetFavoriteUseCaseImpl: SetFavoriteUseCase {
    private let setFavoriteRepository: SetFavoriteRepository
    
    init(setFavoriteRepository: SetFavoriteRepository) {
        self.setFavoriteRepository = setFavoriteRepository
    }
    
    func setFavorite(_ state: Bool, _ boardId: String) -> Observable<Bool> {
        return setFavoriteRepository.setFavorite(state, boardId)
            .do(onNext: { [weak self] result in
                if result {
                    self?.syncWithLocalDatabase(state, boardId)
                }
            })

    }
    
    func syncWithLocalDatabase(_ state: Bool, _ boardId: String) {
        if state {
            SetupInfoService.shared.addSimplePostId(boardId)
        } else {
            SetupInfoService.shared.removeSimplePostId(boardId)
        }
    }
}
