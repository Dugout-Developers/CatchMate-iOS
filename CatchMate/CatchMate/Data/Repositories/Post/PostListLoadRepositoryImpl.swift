//
//  FavoriteLoadRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 8/13/24.
//

import UIKit
import RxSwift

final class PostListLoadRepositoryImpl: PostListLoadRepository {
    private let favoriteLoadDS: PostLoadDataSource
    init(favoriteLoadDS: PostLoadDataSource) {
        self.favoriteLoadDS = favoriteLoadDS
    }
    func loadPostList(isFavorite: Bool, pageNum: Int, gudan: String, gameDate: String) -> RxSwift.Observable<[PostList]> {
        return favoriteLoadDS.loadPostList(isFavorite: isFavorite, pageNum: pageNum, gudan: gudan, gameDate: gameDate)
            .flatMap { dtoList -> Observable<[PostList]> in
                var list = [PostList]()
                dtoList.forEach { dto in
                    if let mapResult = PostMapper().postListDTOtoDomain(dto) {
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
