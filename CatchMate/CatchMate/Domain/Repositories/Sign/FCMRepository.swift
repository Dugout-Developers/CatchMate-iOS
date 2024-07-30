//
//  FCMRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 7/27/24.
//

import UIKit
import RxSwift

protocol FCMRepository {
    func getFCMToken() -> Observable<String>
}
