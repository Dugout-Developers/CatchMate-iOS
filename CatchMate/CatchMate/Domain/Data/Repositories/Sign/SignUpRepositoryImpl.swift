//
//  SignUpRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 7/24/24.
//

import UIKit
import RxSwift

final class SignUpRepositoryImpl: SignUpRepository {
    private let signupDatasource: SignUpDataSourceImpl

    init(signupDatasource: SignUpDataSourceImpl) {
        self.signupDatasource = signupDatasource
    }
    func requestSignUp(_ model: SignUpModel) -> RxSwift.Observable<Result<SignUpResponse, SignUpAPIError>> {
        return signupDatasource.saveUserModel(model)
            .map { result in
                switch result {
                case .success(let dto):
                    let domainModel = SignUpMapper.signUpResponseToDomain(dto)
                    return .success(domainModel)
                case .failure(let error):
                    return .failure(error)
                }
            }
    }
}
