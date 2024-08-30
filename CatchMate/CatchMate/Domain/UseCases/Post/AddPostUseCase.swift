//
//  AddPostUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//

import UIKit
import RxSwift

protocol AddPostUseCase {
    func addPost(_ post: RequestPost) -> Observable<Int>
}

final class AddPostUseCaseImpl: AddPostUseCase {
    private let addPostRepository: AddPostRepository
    
    init(addPostRepository: AddPostRepository) {
        self.addPostRepository = addPostRepository
    }
    
    func addPost(_ post: RequestPost) -> Observable<Int> {
        print("useCase:\(post)")
        return addPostRepository.addPost(post)
    }
}

