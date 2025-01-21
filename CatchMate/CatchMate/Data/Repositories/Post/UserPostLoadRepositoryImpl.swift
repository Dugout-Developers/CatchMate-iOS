//
//  UserPostLoadRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 9/24/24.
//

import UIKit
import RxSwift

final class UserPostLoadRepositoryImpl: UserPostLoadRepository {
    private let userPostDataSource: UserPostLoadDataSource
    init(userPostDataSource: UserPostLoadDataSource) {
        self.userPostDataSource = userPostDataSource
    }
    func loadPostList(userId: Int, page: Int) -> RxSwift.Observable<PostList> {
        return userPostDataSource.loadUserPostList(userId, page: page)
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
