//
//  SignRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import UIKit
import RxSwift

// MARK: - Domain Model (확정 X - Test 버전)
struct LoginModel {
    let id: String
    let email: String
}

protocol SignRepository {
    func kakaoLogin() -> Observable<LoginModel>
    func appleLogin() -> Observable<LoginModel>
    func naverLogin() -> Observable<LoginModel>
}
