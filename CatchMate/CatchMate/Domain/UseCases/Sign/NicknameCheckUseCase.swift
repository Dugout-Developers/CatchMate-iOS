//
//  NicknameCheckUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 7/30/24.
//

import RxSwift

protocol NicknameCheckUseCase {
    func checkNickname(_ nickname: String) -> Observable<Bool>
}

final class NicknameCheckUseCaseImpl: NicknameCheckUseCase {
    private let nicknameRepository: NicknameCheckRepository
    
    init(nicknameRepository: NicknameCheckRepository) {
        self.nicknameRepository = nicknameRepository
    }
    
    func checkNickname(_ nickname: String) -> Observable<Bool> {
        print(nickname)
        return nicknameRepository.checkNickName(nickname)
    }
}
