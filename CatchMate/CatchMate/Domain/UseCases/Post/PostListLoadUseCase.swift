//
//  PostListLoadUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/13/24.
//

import UIKit
import RxSwift

protocol PostListLoadUseCase {
    func loadPostList(pageNum: Int, gudan: [Int], gameDate: String, people: Int) -> Observable<PostList>
}

final class PostListLoadUseCaseImpl: PostListLoadUseCase {
    private let postListRepository: PostListLoadRepository
    
    init(postListRepository: PostListLoadRepository) {
        self.postListRepository = postListRepository
    }
    func loadPostList(pageNum: Int, gudan: [Int], gameDate: String, people: Int = 0) -> Observable<PostList> {
        return postListRepository.loadPostList(pageNum: pageNum, gudan: gudan, gameDate: gameDate, people: people)
            .catch { error in
                return Observable.error(DomainError(error: error, context: .pageLoad, message: "요청에 실패했습니다.").toPresentationError())
            }
    }
    
}
