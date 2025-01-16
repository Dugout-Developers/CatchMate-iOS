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
    func loadMyInfo() -> Observable<UserDTO>
}

final class UserDataSourceImpl: UserDataSource {
    private let tokenDataSource: TokenDataSource
    private var hasTriedRefreshing = false
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    deinit{
        print("deinit")
    }
    
    func loadMyInfo() -> RxSwift.Observable<UserDTO> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refeshToken = self.tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        print("AccessToken: \(token)")
        print("RefreshToken: \(refeshToken)")
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        return APIService.shared.performRequest(type: .loadMyInfo, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: UserDTO.self, refreshToken: refeshToken)
            .map { user in
                LoggerService.shared.debugLog("UserDTO: \(user)")
                return user
            }
            .catch { error in
                LoggerService.shared.debugLog("내정보 load 실패 - \(error)")
                return Observable.error(error)
            }
    }
}
