//
//  ReceivedCountRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 11/13/24.
//

import UIKit
import RxSwift

protocol ReceivedCountRepository {
    func loadCount() -> Observable<Int>
}
