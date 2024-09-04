//
//  UserDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 7/30/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol UserDataSource {
    func refreshAccessToken() -> Observable<String>
    func loadMyInfo() -> Observable<UserDTO>
}

final class UserDataSourceImpl: UserDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func refreshAccessToken() -> RxSwift.Observable<String> {
        guard let base = Bundle.main.baseURL else {
            return Observable.error(NetworkError.notFoundBaseURL)
        }
        guard let token = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }

        return APIService.shared.refreshAccessToken(refreshToken: token)
    }
    
    func loadMyInfo() -> RxSwift.Observable<UserDTO> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        

        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        return APIService.shared.requestAPI(type: .loadMyInfo, parameters: nil, headers: headers, dataType: UserDTO.self)
            .map { user in
                LoggerService.shared.log("UserDTO: \(user)")
                return user
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.error(ReferenceError.notFoundSelf) }
                if error.statusCode == 401 {
                    guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
                        return Observable.error(TokenError.notFoundRefreshToken)
                    }
                    return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
                        .flatMap { newToken -> Observable<UserDTO> in
                            return APIService.shared.requestAPI(type: .loadMyInfo, parameters: nil, headers: headers, dataType: UserDTO.self)
                        }
                        .catch { error in
                            return Observable.error(error)
                        }
                }
                return Observable.error(error)
            }
    }
}
