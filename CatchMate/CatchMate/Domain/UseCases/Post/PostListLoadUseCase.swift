//
//  PostListLoadUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/13/24.
//

import UIKit
import RxSwift

protocol PostListLoadUseCase {
    func loadPostList(pageNum: Int, gudan: [Int], gameDate: String, people: Int, isGuest: Bool) -> Observable<PostList>
}

final class PostListLoadUseCaseImpl: PostListLoadUseCase {
    private let postListRepository: PostListLoadRepository
    
    init(postListRepository: PostListLoadRepository) {
        self.postListRepository = postListRepository
    }
    func loadPostList(pageNum: Int, gudan: [Int], gameDate: String, people: Int = 0, isGuest: Bool = false) -> Observable<PostList> {
        LoggerService.shared.log(level: .info, "게시물 불러오기 \(pageNum)페이지, 구단필터: \(gudan.map{Team(serverId: $0)?.rawValue}), 게임 일자: \(gameDate), 필터 인원: \(people)")
        return postListRepository.loadPostList(pageNum: pageNum, gudan: gudan, gameDate: gameDate, people: people, isGuest: isGuest)
            .catch { error in
                if let localizedError = error as? LocalizedError, -1999...(-1000) ~= localizedError.statusCode {
                    // TokenError
                    let domainError = DomainError(error: error, context: .tokenUnavailable)
                    LoggerService.shared.errorLog(domainError, domain: "load_post", message: error.errorDescription)
                    return Observable.error(domainError)
                }
                LoggerService.shared.errorLog(error, domain: "load_post", message: error.errorDescription)
                return Observable.just(PostList(post: [], isLast: true))
            }
    }
    
}
