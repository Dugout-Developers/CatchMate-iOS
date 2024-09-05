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
        return loadPostRepository.loadPost(postId: postId)  // 첫 번째 Observable 실행
            .concatMap { post -> Observable<(post: Post, type: ApplyType)>  in
                // 첫 번째 로직 완료 후 두 번째 Observable 실행
                guard let myUserId = SetupInfoService.shared.getUserInfo(type: .id) else {
                    return Observable.error(PresentationError.unauthorized(message: "다시 로그인해주세요."))
                }

                // 두 번째 Observable 실행
                return self.applylistRepository.isApply(boardId: Int(postId)!)
                    .map { isApplied in
                        var state: ApplyType = .none
                        
                        if post.writer.userId == myUserId {
                            state = .chat
                        } else if post.maxPerson == post.currentPerson {
                            state = .finished
                        } else if isApplied {
                            state = .applied
                        }

                        // 최종 결과 반환
                        return (post, state)
                    }
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
