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
    private let editPostDS: EditPostDataSource
    
    init(addPostDS: AddPostDataSource, editPostDS: EditPostDataSource) {
        self.addPostDS = addPostDS
        self.editPostDS = editPostDS
    }
    
    func addPost(_ post: RequestPost) -> Observable<Int> {
        guard let post = PostMapper().domainToDto(post) else {
            print("Repositiory: \(post)")
            return Observable.error(ErrorMapper.mapToPresentationError(MappingError.mappingFailed))
        }
        return addPostDS.addPost(post)
            .catch { error in
                return Observable.error(ErrorMapper.mapToPresentationError(error))
            }
    }
    
    func editPost(_ post: RequestEditPost, boardId: Int) -> Observable<Int> {
        guard let post = PostMapper().domainToDto(post) else {
            print("Repository - editPost: \(post)")
            return Observable.error(ErrorMapper.mapToPresentationError(MappingError.mappingFailed))
        }
        return editPostDS.editPost(post, boardId: boardId)
            .catch { error in
                return Observable.error(ErrorMapper.mapToPresentationError(error))
            }
    }
}

