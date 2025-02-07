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
    
    func loadFavoriteList(page: Int) -> RxSwift.Observable<PostList> {
        return loadFavorioteListDS.loadFavoriteList(page: page)
            .flatMap { dto in
                var list = [SimplePost]()
                dto.boardInfoList.forEach { dto in
                    if let mapResult = PostMapper().postListDTOtoDomain( dto) {
                        list.append(mapResult)
                    } else {
                        LoggerService.shared.log("\(dto.boardId) 매핑 실패")
                    }
                }
                return Observable.just(PostList(post: list, isLast: dto.isLast))
            }
    }
    

}
