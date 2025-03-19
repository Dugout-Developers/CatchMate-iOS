//
//  RecivedAppiesRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 9/4/24.
//

import UIKit
import RxSwift

protocol RecivedAppiesRepository {
    func loadRecivedApplies(boardId: Int, page: Int) -> Observable<ReceivedAppliesList>
    func loadReceivedAppliesAll(_ page: Int) -> Observable<ReceivedAppliesList> 
}

