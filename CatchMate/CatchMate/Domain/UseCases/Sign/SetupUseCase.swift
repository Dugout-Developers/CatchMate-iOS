//
//  SetupUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/27/24.
//

import UIKit
import RxSwift

protocol SetupUseCase {
    func setupInfo() -> Observable<SetupResult>
}

final class SetupUseCaseImpl: SetupUseCase {
    private let favoriteListRepository: LoadFavoriteListRepository
    private let userRepository: UserRepository
    
    init(favoriteListRepository: LoadFavoriteListRepository, userRepository: UserRepository) {
        self.favoriteListRepository = favoriteListRepository
        self.userRepository = userRepository
    }
    
    func setupInfo() -> RxSwift.Observable<SetupResult> {
        return Observable.zip(
            favoriteListRepository.loadFavoriteList(),
            userRepository.loadUser()
        )
        .map { (list, user) -> SetupResult in
            let ids = list.map{$0.id}
            return SetupResult(user: user, favoriteList: ids)
        }
        .catch { error in
            // MARK: - 임시 에러수정 -> 서버 옮기기 후 토큰 에러로 되돌리기
            return Observable.error(DomainError(error: error, context: .pageLoad).toPresentationError())
        }
    }
}
