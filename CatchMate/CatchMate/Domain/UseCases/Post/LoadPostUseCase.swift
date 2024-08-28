//
//  LoadPostUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/15/24.
//

import UIKit
import RxSwift

protocol LoadPostUseCase {
    func loadPost(postId: String) -> Observable<Post>
}

final class LoadPostUseCaseImpl: LoadPostUseCase {
    private let loadPostRepository: LoadPostRepository
    
    init(loadPostRepository: LoadPostRepository) {
        self.loadPostRepository = loadPostRepository
    }

    func loadPost(postId: String) -> Observable<Post> {
        return loadPostRepository.loadPost(postId: postId)
    }
    
}
