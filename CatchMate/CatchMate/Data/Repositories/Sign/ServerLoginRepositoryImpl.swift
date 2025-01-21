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
            .map({ response in
                if let provider = LoginType(rawValue: snsModel.loginType) {
                    let gender = Gender(rawValue: snsModel.gender ?? "")
                    return LoginModel(email: snsModel.email, provider: provider, providerId: snsModel.id, accessToken: response.accessToken, refreshToken: response.refreshToken, isFirstLogin: response.isFirstLogin, fcmToken: token, imageString: snsModel.imageUrl, nickName: snsModel.nickName, birth: snsModel.birth, gender: gender)
                } else {
                    throw CodableError.decodingFailed 
                }
            })
    }

}
