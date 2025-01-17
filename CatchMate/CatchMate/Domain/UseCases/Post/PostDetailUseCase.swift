//
//  LoadPostUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/15/24.
//

import UIKit
import RxSwift

protocol PostDetailUseCase {
    func loadPost(postId: String) -> Observable<(post: Post, type: ApplyType, favorite: Bool)>
    func loadApplyInfo(postId: String) -> Observable<MyApplyInfo?>
}

final class PostDetailUseCaseImpl: PostDetailUseCase {
    private let loadPostRepository: LoadPostRepository
    private let applylistRepository: SendAppiesRepository
    init(loadPostRepository: LoadPostRepository, applylistRepository: SendAppiesRepository) {
        self.loadPostRepository = loadPostRepository
        self.applylistRepository = applylistRepository
    }
    func loadPost(postId: String) -> Observable<(post: Post, type: ApplyType, favorite: Bool)> {
        return loadPostRepository.loadPost(postId: postId)
            .map({ post, favorite, type in
                return (post, type, favorite)
            })
            .catch { error in
                return Observable.error(DomainError(error: error, context: .pageLoad))
            }
    }

    
    func loadApplyInfo(postId: String) -> Observable<MyApplyInfo?> {
        return applylistRepository.loadSendApplies()
            .flatMap { list -> Observable<MyApplyInfo?> in
                if let info = list.first(where: { content in
                    content.post.id == postId
                }) {
                    return Observable.just(MyApplyInfo(enrollId: info.enrollId, addInfo: info.addText))
                } else {
                    return Observable.just(nil)
                }
            }
            .catch { error in
                return Observable.error(DomainError(error: error, context: .pageLoad))
            }
    }
}
