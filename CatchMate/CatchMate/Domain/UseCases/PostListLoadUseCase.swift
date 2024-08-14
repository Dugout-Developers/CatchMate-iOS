//
//  PostListLoadUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/13/24.
//

import UIKit
import RxSwift

protocol PostListLoadUseCase {
    func loadPostList(isFavorite: Bool, pageNum: Int, gudan: String, gameDate: String) -> Observable<[PostList]>
}

final class PostListLoadUseCaseImpl: PostListLoadUseCase {
    private let postListRepository: PostListLoadRepository
    
    init(postListRepository: PostListLoadRepository) {
        self.postListRepository = postListRepository
    }
    func loadPostList(isFavorite: Bool, pageNum: Int, gudan: String, gameDate: String) -> Observable<[PostList]> {
        return postListRepository.loadPostList(isFavorite: isFavorite, pageNum: pageNum, gudan: gudan, gameDate: gameDate)
    }
    
}
