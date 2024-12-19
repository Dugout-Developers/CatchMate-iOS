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
    }
}
