//
//  ProfileEditUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 12/12/24.
//

import UIKit
import RxSwift

protocol ProfileEditUseCase {
    func editProfile(nickname: String, team: Team, style: CheerStyles?, image: UIImage?) -> Observable<Bool>
}

final class ProfileEditUseCaseImpl: ProfileEditUseCase {
    private let repository: ProfileEditRepository
    
    init(repository: ProfileEditRepository) {
        self.repository = repository
    }
    
    func editProfile(nickname: String, team: Team, style: CheerStyles?, image: UIImage?) -> Observable<Bool> {
        LoggerService.shared.log(level: .info, "프로필 수정")
        return repository.editProfile(nickname: nickname, team: team, style: style, image: image)
            .flatMap({ state -> Observable<Bool> in
                return Observable.just(state)
            })
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "요청에 실패했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "edit_profile", message: error.errorDescription)
                return Observable.error(domainError)
            }
            
    }
}
