//
//  SetFavoriteRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 8/22/24.
//

import UIKit
import RxSwift

protocol SetFavoriteRepository {
    func setFavorite(_ state: Bool, _ boardID: String) -> Observable<Bool>
}
