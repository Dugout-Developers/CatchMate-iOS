//
//  FavoriteLoadRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 8/13/24.
//

import UIKit
import RxSwift

protocol PostListLoadRepository {
    func loadPostList(pageNum: Int, gudan: String, gameDate: String) -> Observable<[SimplePost]>
}

