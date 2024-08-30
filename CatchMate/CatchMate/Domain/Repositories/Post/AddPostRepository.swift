//
//  AddPostRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//

import UIKit
import RxSwift

protocol AddPostRepository {
    func addPost(_ post: RequestPost) -> Observable<Int>
}
