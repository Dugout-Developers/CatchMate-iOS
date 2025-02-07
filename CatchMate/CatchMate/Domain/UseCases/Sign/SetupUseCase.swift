//
//  SetupUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 8/27/24.
//

import UIKit
import RxSwift

protocol SetupUseCase {
    func setupInfo() -> Observable<SetupUserInfo>
}

final class SetupUseCaseImpl: SetupUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func setupInfo() -> RxSwift.Observable<SetupUserInfo> {
        return userRepository.loadUser()
        .map { user -> SetupUserInfo in
            return SetupUserInfo(id: user.id, email: user.email, nickName: user.nickName, imageUrl: user.profilePicture ?? "", team: user.team)
        }
        .catch { error in
            let domainError = DomainError(error: error, context: .tokenUnavailable)
            LoggerService.shared.errorLog(domainError, domain: "유저정보 불러오기", message: error.errorDescription)
            return Observable.error(domainError)
        }
    }
}
