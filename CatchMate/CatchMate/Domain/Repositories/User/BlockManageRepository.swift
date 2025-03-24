//
//  BlockManageRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 2/17/25.
//

import RxSwift

protocol BlockManageRepository {
    func blockUser(_ userId: Int) -> Observable<Void>
    func unblockUser(_ userId: Int) -> Observable<Void>
}
