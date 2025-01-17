//
//  LoadFavoriteListUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/22/24.
//

import UIKit
import RxSwift

protocol LoadFavoriteListUseCase {
    func execute() -> Observable<[SimplePost]>
    
}

final class LoadFavoriteListUseCaseImpl: LoadFavoriteListUseCase {
    private let loadFavoriteListRepository: LoadFavoriteListRepository
    
    init(loadFavoriteListRepository: LoadFavoriteListRepository) {
        self.loadFavoriteListRepository = loadFavoriteListRepository
    }
    
    func execute() -> RxSwift.Observable<[SimplePost]> {
        return loadFavoriteListRepository.loadFavoriteList()
            .catch { error in
                if let localizedError = error as? LocalizedError, -1999...(-1000) ~= localizedError.statusCode {
                    // TokenError
                    return Observable.error(DomainError(error: error, context: .tokenUnavailable))
                }
                return Observable.just([])
            }
    }
    
}
