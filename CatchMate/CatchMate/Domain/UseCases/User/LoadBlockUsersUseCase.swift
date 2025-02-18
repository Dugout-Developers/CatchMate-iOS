//
//  LoadBlockUsersUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 2/17/25.
//

import UIKit
import RxSwift

protocol LoadBlockUsersUseCase {
    func loadBlockUsers(page: Int) -> Observable<(users: [SimpleUser], isLast: Bool)>
}

final class LoadBlockUsersUseCaseImpl: LoadBlockUsersUseCase {
    private let loadBlockUsersRepo: LoadBlockUsersRepository
    init(loadBlockUsersRepo: LoadBlockUsersRepository) {
        self.loadBlockUsersRepo = loadBlockUsersRepo
    }
    
    func loadBlockUsers(page: Int) -> Observable<(users: [SimpleUser], isLast: Bool)> {
        return loadBlockUsersRepo.loadBlockUsers(page: page)
            .do(onNext: { _ in
                LoggerService.shared.log(level: .info, "차단 유저 목록 조회")
            })
            .catch { error in
                let domainError = DomainError(error: error, context: .pageLoad, message: "차단 유저 정보를 불러오는데 실패했어요")
                LoggerService.shared.errorLog(domainError, domain: "load_blockusers", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
