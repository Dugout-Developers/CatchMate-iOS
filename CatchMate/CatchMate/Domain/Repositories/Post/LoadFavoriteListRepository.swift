//
//  LoadFavoriteListRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 8/22/24.
//

import UIKit
import RxSwift

protocol LoadFavoriteListRepository {
    func loadFavoriteList(page: Int) -> Observable<PostList>
}
