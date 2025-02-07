//
//  TempPostUseCase.swift
//  CatchMate
//
//  Created by 방유빈 on 1/10/25.
//

import RxSwift

protocol TempPostUseCase {
    func execute(_ tempPost: TempPostRequest) -> Observable<Void>
    func loadTempPost() -> Observable<TempPost?>
}

final class TempPostUseCaseImpl: TempPostUseCase {
    private let tempPostRepository: TempPostRepository
    
    init(tempPostRepository: TempPostRepository) {
        self.tempPostRepository = tempPostRepository
    }
    
    func execute(_ tempPost: TempPostRequest) -> RxSwift.Observable<Void> {
        LoggerService.shared.log(level: .info, "게시물 임시 저장")
        return tempPostRepository.tempPost(tempPost)
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "임시저장에 실패했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "temp_post", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
    
    func loadTempPost() -> Observable<TempPost?> {
        LoggerService.shared.log(level: .info, "임시 저장 게시물 불러오기")
        return tempPostRepository.loadTempPost()
            .catch { error in
                let domainError = DomainError(error: error, context: .action, message: "임시저장 게시물을 불러오는데 실패했습니다.")
                LoggerService.shared.errorLog(domainError, domain: "load_temp_post", message: error.errorDescription)
                return Observable.error(domainError)
            }
    }
}
