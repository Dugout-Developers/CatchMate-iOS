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
    func loadApplyInfo(postId: String) -> Observable<MyApplyInfo>
}

final class PostDetailUseCaseImpl: PostDetailUseCase {
    private let loadPostRepository: LoadPostRepository
    private let applyRepository: SendAppiesRepository
    init(loadPostRepository: LoadPostRepository, applyRepository: SendAppiesRepository) {
        self.loadPostRepository = loadPostRepository
        self.applyRepository = applyRepository
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

    
    func loadApplyInfo(postId: String) -> Observable<MyApplyInfo> {
        guard let intId = Int(postId) else {
            return Observable.error(DomainError(error: OtherError.failureTypeCase, context: .action, message: "신청 정보를 불러오는데 실패했습니다."))
        }
        return applyRepository.loadSendApplyDetail(intId)
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "신청 정보를 불러오는데 실패했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "load_post_apply_detail", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }

}
