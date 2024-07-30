//
//  SignUpRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 7/24/24.
//

import UIKit
import RxSwift

protocol SignUpRepository {
    func requestSignUp(_ model: SignUpModel) -> Observable<Result<SignUpResponse, SignUpAPIError>>
}
