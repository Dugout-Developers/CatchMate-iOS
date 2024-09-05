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
        return APIService.shared.requestAPI(type: .loadMyInfo, parameters: nil, headers: headers, dataType: UserDTO.self)
            .map { user in
                LoggerService.shared.log("UserDTO: \(user)")
                return user
            }
            .catch { error in
                print("-------error: \(error)")
                if error.statusCode == 401 {
                    print("재발급")
                    return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
                        .flatMap { newToken -> Observable<UserDTO> in
                            let newheaders: HTTPHeaders = [
                                "AccessToken": newToken
                            ]
                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
                            return APIService.shared.requestAPI(type: .loadMyInfo, parameters: nil, headers: newheaders, dataType: UserDTO.self)
                        }
                        .catch { error in
                            return Observable.error(error)
                        }
                }
                return Observable.error(error)
            }
    }
}
