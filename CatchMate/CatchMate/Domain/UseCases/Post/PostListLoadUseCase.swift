//
//  PostListLoadUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/13/24.
//

import UIKit
import RxSwift

protocol PostListLoadUseCase {
    func loadPostList(pageNum: Int, gudan: [String], gameDate: String, people: Int) -> Observable<[SimplePost]>
}

final class PostListLoadUseCaseImpl: PostListLoadUseCase {
    private let postListRepository: PostListLoadRepository
    
    init(postListRepository: PostListLoadRepository) {
        self.postListRepository = postListRepository
    }
    func loadPostList(pageNum: Int, gudan: [String], gameDate: String, people: Int = 0) -> Observable<[SimplePost]> {
        return postListRepository.loadPostList(pageNum: pageNum, gudan: gudan, gameDate: gameDate, people: people)
    }
    
}
