//
//  SignUpRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 7/24/24.
//

import UIKit
import RxSwift

protocol SignUpRepository {
    func requestSignup(_ model: LoginModel, signupInfo: SignUpModel) -> Observable<SignUpResponse>
}
