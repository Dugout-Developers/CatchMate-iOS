//
//  FCMRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 7/27/24.
//

import UIKit
import RxSwift

final class FCMRepositoryImpl: FCMRepository {
    private let fcmTokenDS: FCMTokenDataSourceImpl
    
    init(fcmTokenDS: FCMTokenDataSourceImpl) {
        self.fcmTokenDS = fcmTokenDS
    }
    func getFCMToken() -> Observable<String> {
        return fcmTokenDS.getFcmToken()
    }

}
