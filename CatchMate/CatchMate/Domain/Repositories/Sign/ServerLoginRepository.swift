//
//  ServerLoginRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 7/27/24.
//

import UIKit
import RxSwift

protocol ServerLoginRepository {
    func login(snsModel: SNSLoginResponse, token: String) -> Observable<LoginModel>
}
