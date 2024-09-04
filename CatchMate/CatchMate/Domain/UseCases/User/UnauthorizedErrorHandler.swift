//
//  UnauthorizedErrorHandler.swift
//  CatchMate
//
//  Created by 방유빈 on 9/4/24.
//

import UIKit
import RxSwift

final class UnauthorizedErrorHandler {
    static let shared = UnauthorizedErrorHandler()

    private var logoutUseCase: LogoutUseCase!
    init() {}
    
    func configure(logoutUseCase: LogoutUseCase) {
        self.logoutUseCase = logoutUseCase
    }

    func handleError() {
        logoutUseCase.deleteToken()
    }

}
