//
//  LoadFavoriteListRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 8/22/24.
//

import UIKit
import RxSwift

final class LoadFavoriteListRepositoryImpl: LoadFavoriteListRepository {
    private let loadFavorioteListDS: LoadFavoriteListDataSource
    
    init(loadFavorioteListDS: LoadFavoriteListDataSource) {
        self.loadFavorioteListDS = loadFavorioteListDS
    }
    
    func loadFavoriteList() -> RxSwift.Observable<[SimplePost]> {
        return loadFavorioteListDS.loadFavoriteList()
            .flatMap { dtoList in
                var list = [SimplePost]()
                dtoList.forEach { dto in
                    print(dto)
                    if let mapResult = PostMapper().favoritePostListDTOtoDomain(dto) {
                        print("append")
                        list.append(mapResult)
                    }
                }
                return Observable.just(list)
            }
            .catch { error in
                return Observable.error(ErrorMapper.mapToPresentationError(error))
            }
    }
    

}
