//
//  LoadChatDetailUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 2/23/25.
//

import RxSwift

protocol LoadChatDetailUseCase {
    func loadChat(_ chatId: Int) -> Observable<ChatListInfo>
}

final class LoadChatDetailUseCaseImpl: LoadChatDetailUseCase {
    private let loadChatRepo: LoadChatDetailRepository
    init(loadChatRepo: LoadChatDetailRepository) {
        self.loadChatRepo = loadChatRepo
    }
    
    func loadChat(_ chatId: Int) -> RxSwift.Observable<ChatListInfo> {
        return loadChatRepo.loadChat(chatId)
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "채팅방 정보 불러오기 실패")
                LoggerService.shared.errorLog(domainError, domain: "load_chatdetail", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
    
    
}
