//
//  SignRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import UIKit
import RxSwift

protocol LoginRepository {
    func kakaoLogin() -> Observable<LoginModel>
    func appleLogin() -> Observable<LoginModel>
    func naverLogin() -> Observable<LoginModel>
}
