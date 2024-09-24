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
    func loadPostList(userId: Int, page: Int) -> RxSwift.Observable<[SimplePost]> {
        return userPostDataSource.loadUserPostList(userId, page: page)
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
