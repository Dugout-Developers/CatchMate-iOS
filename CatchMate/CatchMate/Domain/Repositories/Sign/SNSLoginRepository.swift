//
//  SignRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 6/26/24.
//

import UIKit
import RxSwift

protocol SNSLoginRepository {
    func kakaoLogin() -> Observable<SNSLoginResponse>
    func appleLogin() -> Observable<SNSLoginResponse>
    func naverLogin() -> Observable<SNSLoginResponse>
}
