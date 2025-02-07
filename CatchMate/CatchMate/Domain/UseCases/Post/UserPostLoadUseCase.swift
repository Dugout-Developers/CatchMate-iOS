//
//  UserPostLoadUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 9/24/24.
//

import UIKit
import RxSwift

protocol UserPostLoadUseCase {
    func loadPostList(userId: Int, page: Int) -> Observable<PostList>
}

final class UserPostLoadUseCaseImpl: UserPostLoadUseCase {
    private let userPostListRepository: UserPostLoadRepository
    
    init(userPostListRepository: UserPostLoadRepository) {
        self.userPostListRepository = userPostListRepository
    }
    func loadPostList(userId: Int, page: Int) -> Observable<PostList>{
        LoggerService.shared.log(level: .info, "\(userId)번 유저 게시물 로드 - \(page)페이지")
        return userPostListRepository.loadPostList(userId: userId, page: page)
            .catch { error in
//                if let localizedError = error as? LocalizedError, -1999...(-1000) ~= localizedError.statusCode {
//                    // TokenError
//                    return Observable.error(DomainError(error: error, context: .tokenUnavailable))
//                }
                let domainError = DomainError(error: error, context: .pageLoad)
                LoggerService.shared.errorLog(domainError, domain: "load_userpost", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
    
}

