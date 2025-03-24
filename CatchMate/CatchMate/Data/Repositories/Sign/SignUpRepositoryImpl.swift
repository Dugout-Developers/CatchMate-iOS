//
//  SignUpRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 7/24/24.
//

import UIKit
import RxSwift

final class SignUpRepositoryImpl: SignUpRepository {
    func requestSignup(_ model: LoginModel, signupInfo: SignUpModel) -> RxSwift.Observable<SignUpResponse> {
        let gender = signupInfo.gender == .man ? "M" : "F"
        let request = SignUpRequest(email: model.email, provider: model.provider.rawValue, providerId: model.providerId, gender: gender, profileImageUrl: model.imageString, fcmToken: model.fcmToken, nickName: signupInfo.nickName, birthDate: signupInfo.birth, favoriteClubId: signupInfo.team.serverId, watchStyle: signupInfo.cheerStyle?.rawValue)
        return signupDatasource.saveUserModel(request)
            .map { dto -> SignUpResponse in
                return SignUpResponse(userId: String(dto.userId), createdAt: dto.createdAt, accessToken: dto.accessToken, refreshToken: dto.refreshToken)
            }
    }
    
    private let signupDatasource: SignUpDataSourceImpl

    init(signupDatasource: SignUpDataSourceImpl) {
        self.signupDatasource = signupDatasource
    }
   
}
