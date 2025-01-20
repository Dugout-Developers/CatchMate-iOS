//
//  LoadFavoriteListUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/22/24.
//

import UIKit
import RxSwift

protocol LoadFavoriteListUseCase {
    func execute(page: Int) -> Observable<PostList>
    
}

final class LoadFavoriteListUseCaseImpl: LoadFavoriteListUseCase {
    private let loadFavoriteListRepository: LoadFavoriteListRepository
    
    init(loadFavoriteListRepository: LoadFavoriteListRepository) {
        self.loadFavoriteListRepository = loadFavoriteListRepository
    }
    
    func execute(page: Int) -> RxSwift.Observable<PostList> {
        return loadFavoriteListRepository.loadFavoriteList(page: page)
            .catch { error in
                if let localizedError = error as? LocalizedError, -1999...(-1000) ~= localizedError.statusCode {
                    // TokenError
                    return Observable.error(DomainError(error: error, context: .tokenUnavailable))
                }
                return Observable.just(PostList(post: [], isLast: true))
            }
    }
    
}
