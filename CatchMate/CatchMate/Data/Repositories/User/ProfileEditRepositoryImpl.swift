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
    
    func editProfile(nickname: String, team: Team, style: CheerStyles?) -> RxSwift.Observable<Bool> {
        
        let requestModel = ProfileEditRequestDTO(nickname: nickname, description: "", favGudan: team.rawValue, watchStyle: style == nil ? "" : style!.rawValue)
        return profileEditDS.editProfile(editModel: requestModel)
            .map { dto -> Bool in
                return true
            }
            .catch { error in
                return Observable.error(ErrorMapper.mapToPresentationError(error))
            }
    }
}
