//
//  LoadNoticeListUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 2/26/25.
//
import RxSwift

protocol LoadNoticeListUseCase {
    func loadNotices(_ page: Int) -> Observable<(notices: [Announcement], isLast: Bool)>
}

final class LoadNoticeListUseCaseImpl: LoadNoticeListUseCase {
    private let loadNoticeRepo: LoadNoticeListRepsitory
    init(loadNoticeRepo: LoadNoticeListRepsitory) {
        self.loadNoticeRepo = loadNoticeRepo
    }
    
    func loadNotices(_ page: Int) -> RxSwift.Observable<(notices: [Announcement], isLast: Bool)> {
        return loadNoticeRepo.loadNotices(page)
            .do(onNext: { _ in
                LoggerService.shared.log(level: .info, "공지사항 \(page+1)page 조회")
            })
            .catch { error in
                let domainError = DomainError(error: error, context: .pageLoad, message: "공지사항을 불러오는데 실패했어요")
                LoggerService.shared.errorLog(domainError, domain: "load_notices", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
    
    
}
