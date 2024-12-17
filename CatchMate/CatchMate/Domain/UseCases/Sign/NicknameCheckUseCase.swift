//
//  NicknameCheckUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 7/30/24.
//

import RxSwift

protocol NicknameCheckUseCase {
    func execute(_ nickname: String) -> Observable<Bool>
}

final class NicknameCheckUseCaseImpl: NicknameCheckUseCase {
    private let nicknameRepository: NicknameCheckRepository
    
    init(nicknameRepository: NicknameCheckRepository) {
        self.nicknameRepository = nicknameRepository
    }
    
    func execute(_ nickname: String) -> Observable<Bool> {
        return nicknameRepository.checkNickName(nickname)
    }
}
