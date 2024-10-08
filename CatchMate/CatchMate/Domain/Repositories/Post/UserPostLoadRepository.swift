//
//  UserPostLoadRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 9/24/24.
//

import UIKit
import RxSwift

protocol UserPostLoadRepository {
    func loadPostList(userId: Int, page: Int) -> Observable<[SimplePost]>
}

