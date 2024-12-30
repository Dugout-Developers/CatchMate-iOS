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
        return repository.editProfile(nickname: nickname, team: team, style: style, image: image)
    }
}
