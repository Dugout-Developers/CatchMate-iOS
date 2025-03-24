//
//  TempPostRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 1/9/25.
//

import RxSwift

final class TempPostRepositoryImpl: TempPostRepository {
    private let tempPostDS: TempPostDataSource
    private let loadTempPostDS: LoadTempPostDataSource
    
    init(tempPostDS: TempPostDataSource, loadTempPostDS: LoadTempPostDataSource) {
        self.tempPostDS = tempPostDS
        self.loadTempPostDS = loadTempPostDS
    }
    
    func tempPost(_ post: TempPostRequest) -> RxSwift.Observable<Void> {
        guard let dto = PostMapper().domainToDto(post) else {
            return Observable.error(MappingError.mappingFailed)
        }
        return tempPostDS.tempPost(dto)
            .map { _ in 
                return ()
            }
    }
    
    func loadTempPost() -> Observable<TempPost?> {
        return loadTempPostDS.loadTempPost()
            .map { dto in
                if let dto = dto {
                    let tempPost = PostMapper().dtoToDomainTemp(dto)
                    return tempPost
                }
                return nil
            }
    }
    
}
