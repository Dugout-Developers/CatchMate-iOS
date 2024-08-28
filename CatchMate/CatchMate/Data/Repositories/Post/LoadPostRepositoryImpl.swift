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
    
    func loadPost(postId: String) -> Observable<Post> {
        guard let id = Int(postId) else {
            LoggerService.shared.log("postId Int 변환 실패 형식 오류", level: .error)
            return Observable.error(PresentationError.informational(message: "게시글을 불러올 수 없습니다."))
        }
        return loadPostDS.laodPost(postId: id)
            .flatMap { dto -> Observable<Post> in
                if let mapResult = PostMapper().dtoToDomain(dto) {
                    return Observable.just(mapResult)
                } else {
                    return Observable.error(ErrorMapper.mapToPresentationError(MappingError.invalidData))
                }
            }
            .catch { error in
                return Observable.error(ErrorMapper.mapToPresentationError(error))
            }
    }
}

