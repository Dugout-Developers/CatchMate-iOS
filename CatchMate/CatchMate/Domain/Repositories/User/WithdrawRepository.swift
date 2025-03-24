//
//  WithdrawRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 3/6/25.
//

import RxSwift

protocol WithdrawRepository {
    func withdraw() -> Observable<Void>
}
