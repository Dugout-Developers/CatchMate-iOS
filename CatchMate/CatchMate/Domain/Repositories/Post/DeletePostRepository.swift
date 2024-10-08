//
//  DeletePostRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 9/27/24.
//

import UIKit
import RxSwift

protocol DeletePostRepository {
    func deletePost(postId: Int) -> Observable<Void>
}
