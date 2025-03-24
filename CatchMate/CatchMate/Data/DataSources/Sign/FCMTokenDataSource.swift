//
//  FCMTokenDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 7/23/24.
//

import UIKit
import RxSwift
import FirebaseMessaging

protocol FCMTokenDataSource {
    func getFcmToken() -> Observable<String>
}

final class FCMTokenDataSourceImpl: FCMTokenDataSource {
    func getFcmToken() -> Observable<String> {
        return Observable.create { observer in
            Messaging.messaging().token { token, error in
                if let error = error {
                    observer.onError(error)
                } else if let token = token {
                    LoggerService.shared.log(level: .debug, "FCM Token : \(token)")
                    observer.onNext(token)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}
