//
//  LoginMapper.swift
//  CatchMate
//
//  Created by 방유빈 on 6/12/24.
//

import UIKit

final class LoginMapper {
    static func snsToLoginRequest(_ snsModel: SNSLoginResponse, _ token: String) -> LoginRequset {
        return LoginRequset(provideId: snsModel.id, provider: snsModel.loginType, email: snsModel.email, picture: snsModel.imageUrl ?? "", fcmToken: token)
    }
}
