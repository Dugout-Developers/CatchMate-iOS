//
//  LoadFavoriteListUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/22/24.
//

import UIKit
import RxSwift

protocol LoadFavoriteListUseCase {
    func loadFavoriteList() -> Observable<[SimplePost]>
    func cancelFavoriteList(_ postId: String) -> Observable<Void>
}

final class LoadFavoriteListUseCaseImpl: LoadFavoriteListUseCase {
    private let loadFavoriteListRepository: LoadFavoriteListRepository
    private let setFavortiteRepository: SetFavoriteRepository
    
    init(loadFavoriteListRepository: LoadFavoriteListRepository, setFavortiteRepository: SetFavoriteRepository) {
        self.loadFavoriteListRepository = loadFavoriteListRepository
        self.setFavortiteRepository = setFavortiteRepository
    }
    
    func loadFavoriteList() -> RxSwift.Observable<[SimplePost]> {
        return loadFavoriteListRepository.loadFavoriteList()
    }
    func cancelFavoriteList(_ postId: String) -> Observable<Void> {
        return setFavortiteRepository.setFavorite(false, postId)
            .map { _ in
                return ()
            }
    }
    
}
