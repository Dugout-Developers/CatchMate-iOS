//
//  LoadPostUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/15/24.
//

import UIKit
import RxSwift

protocol PostDetailUseCase {
    func loadPost(postId: String) -> Observable<(post: Post, type: ApplyType)>
    func loadApplyInfo(postId: String) -> Observable<MyApplyInfo?>
}

final class PostDetailUseCaseImpl: PostDetailUseCase {
    private let loadPostRepository: LoadPostRepository
    private let applylistRepository: SendAppiesRepository
    init(loadPostRepository: LoadPostRepository, applylistRepository: SendAppiesRepository) {
        self.loadPostRepository = loadPostRepository
        self.applylistRepository = applylistRepository
    }

    func loadPost(postId: String) -> Observable<(post: Post, type: ApplyType)> {
        let loadPost = loadPostRepository.loadPost(postId: postId)
        let checkApply = applylistRepository.isApply(boardId: Int(postId)!)
        return Observable.zip(loadPost, checkApply)
            .flatMap { post, isApplied -> Observable<(post: Post, type: ApplyType)> in
                var state = ApplyType.none
                guard let myUserId = SetupInfoService.shared.getUserInfo(type: .id) else {
                    return Observable.error(PresentationError.unauthorized(message: "다시 로그인해주세요."))
                }
                if post.writer.userId == myUserId {
                    state = .chat
                } else if post.maxPerson == post.currentPerson {
                    state = .finished
                } else if isApplied {
                    state = .applied
                } else {
                    state = .none
                }
                return Observable.just((post, state))
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
    }
}
