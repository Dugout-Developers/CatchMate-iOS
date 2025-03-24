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
        LoggerService.shared.log(level: .info, "찜한 게시물 불러오기")
        return loadFavoriteListRepository.loadFavoriteList(page: page)
            .catch { error in
                if let localizedError = error as? LocalizedError, -1999...(-1000) ~= localizedError.statusCode {
                    // TokenError
                    let domainError = DomainError(error: error, context: .tokenUnavailable)
                    LoggerService.shared.errorLog(domainError, domain: "load_favorite", message: error.errorDescription)
                    return Observable.error(domainError)
                }
                LoggerService.shared.errorLog(error, domain: "load_favorite", message: error.errorDescription)
                return Observable.just(PostList(post: [], isLast: true))
            }
    }
    
}
