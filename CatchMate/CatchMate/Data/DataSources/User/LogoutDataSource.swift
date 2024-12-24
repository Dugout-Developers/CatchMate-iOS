//
//  LogoutDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol LogoutDataSource {
    func logout() -> Observable<Bool>
    func deleteToken()
}
struct deleteTokeDTO: Codable {
    let state: Bool
}

final class LogoutDataSourceImpl: LogoutDataSource {
    private let tokenDataSource: TokenDataSource
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    func logout() -> RxSwift.Observable<Bool> {
        LoggerService.shared.debugLog("--------------Logout--------------")
        guard let base = Bundle.main.baseURL else {
            LoggerService.shared.log("로그아웃 - BaseUrl 찾기 실패", level: .error)
            return Observable.error(NetworkError.notFoundBaseURL)
        }
        let url = base + "/auth/logout"
        guard let token = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "RefreshToken": token
        ]
        return RxAlamofire.requestJSON(.delete, url, encoding: JSONEncoding.default, headers: headers)
            .flatMap { [weak self] (response, data) -> Observable<Bool> in
                guard let self = self else { return Observable.error(OtherError.notFoundSelf) }
                if response.statusCode == 200 {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let refreshResponse = try JSONDecoder().decode(deleteTokeDTO.self, from: jsonData)
                        LoggerService.shared.debugLog("\(refreshResponse)")
                        if refreshResponse.state {
                            _ = tokenDataSource.deleteToken(for: .accessToken)
                            _ = tokenDataSource.deleteToken(for: .refreshToken)
                            return Observable.just(true)
                        }
                        return Observable.just(false)
                    } catch {
                        LoggerService.shared.log("로그아웃 - 로그아웃 토큰 데이터 디코딩 오류", level: .error)
                        return Observable.error(CodableError.decodingFailed)
                    }
                } else {
                    LoggerService.shared.log("로그아웃 실패: \(response.statusCode): \(response.debugDescription)", level: .error)
                    let error = APIService.shared.mapServerError(statusCode: response.statusCode)
                    return Observable.error(error)
                }
            }
    }
    
    func deleteToken() {
        _ = tokenDataSource.deleteToken(for: .accessToken)
        _ = tokenDataSource.deleteToken(for: .refreshToken)
    }
}
