//
//  UserPostLoadUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 9/24/24.
//

import UIKit
import RxSwift

protocol UserPostLoadUseCase {
    func loadPostList(userId: Int, page: Int) -> Observable<[SimplePost]>
}

final class UserPostLoadUseCaseImpl: UserPostLoadUseCase {
    private let userPostListRepository: UserPostLoadRepository
    
    init(userPostListRepository: UserPostLoadRepository) {
        self.userPostListRepository = userPostListRepository
    }
    func loadPostList(userId: Int, page: Int) -> Observable<[SimplePost]>{
        return userPostListRepository.loadPostList(userId: userId, page: page)
            .catch { error in
                return Observable.error(DomainError(error: error, context: .pageLoad))
            }
    }
    
}

