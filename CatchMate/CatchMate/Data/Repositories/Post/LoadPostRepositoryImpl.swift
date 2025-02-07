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
    
    func loadPost(postId: String) -> Observable<(post: Post, isFavorite: Bool, applyType: ApplyType)> {
        guard let id = Int(postId) else {
            LoggerService.shared.log("postId Int 변환 실패 형식 오류")
            return Observable.error(PresentationError.showErrorPage)
        }
        return loadPostDS.loadPost(postId: id)
            .flatMap { dto -> Observable<(post: Post, isFavorite: Bool, applyType: ApplyType)> in
                let type: ApplyType
                
                if dto.buttonStatus == "VIEW CHAT" {
                    type = ApplyType(serverValue: "VIEW CHAT")
                } else if dto.maxPerson == dto.currentPerson {
                    type = ApplyType(serverValue: "FINISHED")
                } else {
                    type = ApplyType(serverValue: dto.buttonStatus ?? "")
                }
                
                if let mapResult = PostMapper().dtoToDomain(dto) {
                    return Observable.just((mapResult, dto.bookMarked ?? false, type))
                } else {
                    return Observable.error(MappingError.invalidData)
                }
            }
    }
}

