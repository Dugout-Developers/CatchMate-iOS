//
//  NicknameCheckRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 7/30/24.
//

import UIKit
import RxSwift

protocol NicknameCheckRepository {
    func checkNickName(_ nickname: String) -> Observable<Bool>
}
