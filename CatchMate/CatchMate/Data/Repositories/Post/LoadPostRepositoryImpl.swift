//
//  LoadPostRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 8/15/24.
//

import UIKit
import RxSwift

final class LoadPostRepositoryImpl: LoadPostRepository {
    private let loadPostDS: LoadPostDataSource
    
    init(loadPostDS: LoadPostDataSource) {
        self.loadPostDS = loadPostDS
    }
    
    func loadPost(postId: String) -> Observable<(post: Post, isFavorite: Bool)> {
        guard let id = Int(postId) else {
            LoggerService.shared.log("postId Int 변환 실패 형식 오류", level: .error)
            return Observable.error(PresentationError.showErrorPage)
        }
        return loadPostDS.loadPost(postId: id)
            .flatMap { dto -> Observable<(post: Post, isFavorite: Bool)> in
                if let mapResult = PostMapper().dtoToDomain(dto) {
                    return Observable.just((mapResult, dto.bookMarked ?? false))
                } else {
                    return Observable.error(ErrorMapper.mapToPresentationError(MappingError.invalidData))
                }
            }
            .catch { error in
                return Observable.error(ErrorMapper.mapToPresentationError(error))
            }
    }
}

