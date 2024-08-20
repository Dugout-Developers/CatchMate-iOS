//
//  FavoriteLoadRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 8/13/24.
//

import UIKit
import RxSwift

final class PostListLoadRepositoryImpl: PostListLoadRepository {
    private let favoriteLoadDS: PostListLoadDataSource
    init(favoriteLoadDS: PostListLoadDataSource) {
        self.favoriteLoadDS = favoriteLoadDS
    }
    func loadPostList(pageNum: Int, gudan: String, gameDate: String) -> RxSwift.Observable<[SimplePost]> {
        return favoriteLoadDS.loadPostList(pageNum: pageNum, gudan: gudan, gameDate: gameDate)
            .flatMap { dtoList -> Observable<[SimplePost]> in
                var list = [SimplePost]()
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
