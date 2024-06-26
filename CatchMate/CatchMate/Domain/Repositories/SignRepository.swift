//
//  SignRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import UIKit
import RxSwift

struct LoginModel {
    let id: String
        let name: String
        let email: String
}
protocol SignRepository {
    func kakaoLogin() -> Observable<LoginModel>
}
