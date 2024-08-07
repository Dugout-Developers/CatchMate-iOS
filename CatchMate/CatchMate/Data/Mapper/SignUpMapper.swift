//
//  SignUpmapper.swift
//  CatchMate
//
//  Created by 방유빈 on 7/24/24.
//

import UIKit

final class SignUpMapper {
    static func signUpResponseToDomain(_ dto: SignUpResponseDTO) -> SignUpResponse {
        return SignUpResponse(userId: dto.userId, createdAt: dto.createdAt)
    }
}
