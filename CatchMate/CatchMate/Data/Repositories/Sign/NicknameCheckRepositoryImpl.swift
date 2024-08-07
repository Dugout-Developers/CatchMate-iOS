//
//  NicknameCheckRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 7/30/24.
//

import UIKit
import RxSwift

final class NicknameCheckRepositoryImpl: NicknameCheckRepository {
    private let nicknameDS: NicknameCheckDataSourceImpl
    
    init(nicknameDS: NicknameCheckDataSourceImpl) {
        self.nicknameDS = nicknameDS
    }
    
    func checkNickName(_ nickname: String) -> RxSwift.Observable<Bool> {
        nicknameDS.checkNickname(nickname)
    }
    
}
