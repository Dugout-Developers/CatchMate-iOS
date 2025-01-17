//
//  SetFavoriteRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 8/22/24.
//

import UIKit
import RxSwift

final class SetFavoriteRepositoryImpl: SetFavoriteRepository {
    private let setFavoriteDS: SetFavoriteDataSource
    
    init(setFavoriteDS: SetFavoriteDataSource) {
        self.setFavoriteDS = setFavoriteDS
    }
    
    func setFavorite(_ state: Bool, _ boardID: String) -> RxSwift.Observable<Bool> {
        if state {
            return setFavoriteDS.setFavorite(boardID)
                .flatMap { state in
                    LoggerService.shared.log("setFavorite Repository 데이터 변환 완료")
                    return Observable.just(state)
                }
        } else {
            return setFavoriteDS.deleteFavorite(boardID)
                .flatMap { state in
                    LoggerService.shared.log("setFavorite Repository 데이터 변환 완료")
                    return Observable.just(state)
                }
        }
    }
}
