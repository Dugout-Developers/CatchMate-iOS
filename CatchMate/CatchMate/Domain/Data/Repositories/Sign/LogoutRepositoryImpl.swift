//
//  LogoutRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

import UIKit
import RxSwift

final class LogoutRepositoryImpl: LogoutRepository {
    private let lopgoutDS: LogoutDataSourceImpl
    
    init(lopgoutDS: LogoutDataSourceImpl) {
        self.lopgoutDS = lopgoutDS
    }
    
    func logout(token: String) -> RxSwift.Observable<Bool> {
        return lopgoutDS.logout(token: token)
    }

}
