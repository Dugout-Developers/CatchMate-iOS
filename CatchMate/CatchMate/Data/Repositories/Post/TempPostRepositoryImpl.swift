//
//  TempPostRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 1/9/25.
//

import RxSwift

final class TempPostRepositoryImpl: TempPostRepository {
    private let tempPostDS: TempPostDataSource
    
    init(tempPostDS: TempPostDataSource) {
        self.tempPostDS = tempPostDS
    }
    
    func tempPost(_ post: TempPostRequest) -> RxSwift.Observable<Void> {
        guard let dto = PostMapper().domainToDto(post) else {
            print("TempPostRepositiory: \(post)")
            return Observable.error(ErrorMapper.mapToPresentationError(MappingError.mappingFailed))
        }
        print(dto)
        return tempPostDS.tempPost(dto)
            .map { _ in 
                return ()
            }
    }
    
    
}
