//
//  LoadChatDetailRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 2/23/25.
//
import RxSwift

final class LoadChatDetailRepositoryImpl: LoadChatDetailRepository {
    private let loadChatDS: LoadChatDetailDataSource
    init(loadChatDS: LoadChatDetailDataSource) {
        self.loadChatDS = loadChatDS
    }
    
    func loadChat(_ chatId: Int) -> RxSwift.Observable<ChatListInfo> {
        return loadChatDS.loadChatDetail(chatId)
            .flatMap { dto -> Observable<ChatListInfo> in
                let chatMapper = ChatMapper()
                guard let mappingResult = chatMapper.dtoToDomain(dto) else {
                    return Observable.error(MappingError.invalidData)
                }
                return Observable.just(mappingResult)
            }
    }
    
    
}
