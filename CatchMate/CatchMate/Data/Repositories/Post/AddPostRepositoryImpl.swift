//
//  AddPostRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//

import UIKit
import RxSwift

final class AddPostRepositoryImpl: AddPostRepository {
    private let addPostDS: AddPostDataSource
    
    init(addPostDS: AddPostDataSource) {
        self.addPostDS = addPostDS
    }
    
    func addPost(_ post: RequestPost) -> Observable<Void> {
        guard let post = PostMapper().domainToDto(post) else {
            print("Repositiory: \(post)")
            return Observable.error(ErrorMapper.mapToPresentationError(MappingError.mappingFailed))
        }
        return addPostDS.addPost(post)
            .catch { error in
                return Observable.error(ErrorMapper.mapToPresentationError(error))
            }
    }
}

