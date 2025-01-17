//
//  ProfileEditRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 12/13/24.
//

import UIKit
import RxSwift

final class ProfileEditRepositoryImpl: ProfileEditRepository {
    
    private let profileEditDS: ProfileEditDataSource
    init(profileEditDS: ProfileEditDataSource) {
        self.profileEditDS = profileEditDS
    }
    
    func editProfile(nickname: String, team: Team, style: CheerStyles?, image: UIImage?) -> RxSwift.Observable<Bool> {
        
        let requestModel = ProfileEdit(nickName: nickname, team: team, style: style, image: image)
        let dto = UserMapper().profileEditRequestDomainToDTO(domain: requestModel)
        return profileEditDS.editProfile(editModel: dto)
            .map { dto -> Bool in
                return dto.state
            }
    }
}
