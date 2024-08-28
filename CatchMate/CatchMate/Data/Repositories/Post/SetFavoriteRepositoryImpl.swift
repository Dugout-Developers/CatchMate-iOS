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
    
    func setFavorite(_ state: Bool, _ boardID: String) -> RxSwift.Observable<[SimplePost]> {
        return setFavoriteDS.setFavorite(state, boardID)
            .flatMap { dtoList in
                var list = [SimplePost]()
                dtoList.forEach { dto in
                    if let mapResult = PostMapper().postListDTOtoDomain(dto) {
                        list.append(mapResult)
                    }
                }
                LoggerService.shared.log("setFavorite Repository 데이터 변환 완료")
                return Observable.just(list)
            }
            .catch { error in
                return Observable.error(ErrorMapper.mapToPresentationError(error))
            }
    }
}
