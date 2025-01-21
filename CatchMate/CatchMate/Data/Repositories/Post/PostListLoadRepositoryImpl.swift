//
//  FavoriteLoadRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 8/13/24.
//

import UIKit
import RxSwift

final class PostListLoadRepositoryImpl: PostListLoadRepository {
    private let postListLoadDS: PostListLoadDataSource
    init(postListLoadDS: PostListLoadDataSource) {
        self.postListLoadDS = postListLoadDS
    }
    func loadPostList(pageNum: Int, gudan: [Int], gameDate: String, people: Int) -> RxSwift.Observable<PostList> {
        return postListLoadDS.loadPostList(pageNum: pageNum, gudan: gudan, gameDate: gameDate, people: people)
            .flatMap { dto -> Observable<PostList> in
                var list = [SimplePost]()
                dto.boardInfoList.forEach { dto in
                    if let mapResult = PostMapper().postListDTOtoDomain(dto) {
                        list.append(mapResult)
                    }
                }
                return Observable.just(PostList(post: list, isLast: dto.isLast))
            }
    }
}
