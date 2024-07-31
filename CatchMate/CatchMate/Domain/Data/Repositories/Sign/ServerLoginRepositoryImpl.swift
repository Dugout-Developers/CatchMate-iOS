//
//  ServerLoginRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 7/27/24.
//

import UIKit
import RxSwift

final class ServerLoginRepositoryImpl: ServerLoginRepository {
    
    private let serverLoginDS: ServerLoginDataSourceImpl
    
    init(serverLoginDS: ServerLoginDataSourceImpl) {
        self.serverLoginDS = serverLoginDS
    }
    func login(snsModel: SNSLoginResponse, token: String) -> RxSwift.Observable<LoginModel> {
        return serverLoginDS.postLoginRequest(snsModel, token)
    }

}
