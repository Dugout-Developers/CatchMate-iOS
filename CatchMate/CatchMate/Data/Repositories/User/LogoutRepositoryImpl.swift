//
//  LogoutRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

import UIKit
import RxSwift

final class LogoutRepositoryImpl: LogoutRepository {
    private let logoutDS: LogoutDataSourceImpl
    
    init(logoutDS: LogoutDataSourceImpl) {
        self.logoutDS = logoutDS
    }
    
    func logout() -> RxSwift.Observable<Bool> {
        return logoutDS.logout()
            .catch { error in
                return Observable.error(ErrorMapper.mapToPresentationError(error))
            }
    }
    
    func deleteToken() {
        
    }

}
