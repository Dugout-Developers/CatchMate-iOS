//
//  SendAppiesRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 9/5/24.
//

import UIKit
import RxSwift

protocol SendAppiesRepository {
    func loadSendApplies(page: Int) -> Observable<Applys>
    func loadSendApplyDetail(_ boardId: Int) -> Observable<MyApplyInfo>
}
