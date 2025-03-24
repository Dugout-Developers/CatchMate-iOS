//
//  ProfileRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 12/12/24.
//

import UIKit
import RxSwift

protocol ProfileEditRepository {
    func editProfile(nickname: String, team: Team, style: CheerStyles?, image: UIImage?) -> Observable<Bool>
}
