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
        LoggerService.shared.log(level: .info, "\(postId)번 게시물 디테일 불러오기")
        return loadPostRepository.loadPost(postId: postId)
            .map({ post, favorite, type in
                return (post, type, favorite)
            })
            .catch { error in
                let domainError = DomainError(error: error, context: .pageLoad)
                LoggerService.shared.errorLog(domainError, domain: "load_post_detail", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }

    
    func loadApplyInfo(postId: String) -> Observable<MyApplyInfo?> {
        // TODO: - 임시값 페이지 0 -> API 요청 필요
        return applylistRepository.loadSendApplies(page: 0)
            .flatMap { list -> Observable<MyApplyInfo?> in
                if let info = list.applys.first(where: { content in
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
