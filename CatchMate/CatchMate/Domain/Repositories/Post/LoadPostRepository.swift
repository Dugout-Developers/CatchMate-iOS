//
//  LoadPostRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 8/15/24.
//

import RxSwift

protocol LoadPostRepository {
    func loadPost(postId: String) -> Observable<(post: Post, isFavorite: Bool)>
}
