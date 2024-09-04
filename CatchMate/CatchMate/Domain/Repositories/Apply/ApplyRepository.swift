//
//  ApplyRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 9/2/24.
//

import UIKit
import RxSwift

protocol ApplyRepository {
    func applyPost(_ boardId: String, addInfo: String) -> Observable<Int>
}
