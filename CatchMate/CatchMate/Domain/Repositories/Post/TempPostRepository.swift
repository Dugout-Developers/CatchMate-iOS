//
//  TempPostRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 1/10/25.
//

import RxSwift

protocol TempPostRepository {
    func tempPost(_ post: TempPostRequest) -> Observable<Void>
    func loadTempPost() -> Observable<TempPost?>
}
