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
    func refreshAccessToken() -> RxSwift.Observable<String> {
        guard let base = Bundle.main.baseURL else {
            return Observable.error(NetworkError.notFoundBaseURL)
        }
        guard let token = KeychainService.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let url = base + "/auth/reissue"
        let headers: HTTPHeaders = [
            "RefreshToken": token
        ]
        return RxAlamofire.requestJSON(.post, url, encoding: JSONEncoding.default, headers: headers)
            .flatMap { (response, data) -> Observable<String> in
                if response.statusCode == 200 {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let refreshResponse = try JSONDecoder().decode(RefreshTokenResponseDTO.self, from: jsonData)
                        KeychainService.saveToken(token: refreshResponse.accessToken, for: .accessToken)
                        return Observable.just(refreshResponse.accessToken)
                    } catch {
                        return Observable.error(CodableError.decodingFailed)
                    }
                } else {
                    if 400..<500 ~= response.statusCode {
                        return Observable.error(NetworkError.clientError(statusCode: response.statusCode))
                    } else if 500..<600 ~= response.statusCode {
                        return Observable.error(NetworkError.serverError(statusCode: response.statusCode))
                    } else {
                        return Observable.error(NetworkError.unownedError(statusCode: response.statusCode))
                    }
                }
            }
    }
    
    func loadMyInfo() -> RxSwift.Observable<UserDTO> {
        guard let base = Bundle.main.baseURL else {
            return Observable.error(NetworkError.notFoundBaseURL)
        }
        guard let token = KeychainService.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        
        let url = base + "/user/profile"
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        return performRequest(url: url, headers: headers, retryCount: 0)
    }
    
    private func performRequest(url: String, headers: HTTPHeaders, retryCount: Int) -> Observable<UserDTO> {
            return RxAlamofire.requestData(.get, url, encoding: JSONEncoding.default, headers: headers)
                .flatMap { (response, data) -> Observable<UserDTO> in
                    guard 200..<300 ~= response.statusCode else {
                        LoggerService.shared.debugLog("User Data Request Error : \(response.statusCode) \(response.debugDescription)")
                        if response.statusCode == 401 {
                            return Observable.error(NetworkError.clientError(statusCode: 401))
                        }
                        if 400..<500 ~= response.statusCode {
                            return Observable.error(NetworkError.clientError(statusCode: response.statusCode))
                        } else if 500..<600 ~= response.statusCode {
                            return Observable.error(NetworkError.serverError(statusCode: response.statusCode))
                        } else {
                            return Observable.error(NetworkError.unownedError(statusCode: response.statusCode))
                        }
                    }
                    
                    do {
                        let userResponse = try JSONDecoder().decode(UserDTO.self, from: data)
                        LoggerService.shared.log("UserDTO: \(userResponse)")
                        return Observable.just(userResponse)
                    } catch {
                        LoggerService.shared.log("Decoding Error", level: .error)
                        if let jsonString = String(data: data, encoding: .utf8) {
                            LoggerService.shared.debugLog("Decoding Error - JSON 데이터 : \(jsonString)")
                        } else {
                            LoggerService.shared.debugLog("Decoding Error: Json String 변환 불가")
                        }
                        return Observable.error(CodableError.decodingFailed)
                    }
                }
                .catch { error -> Observable<UserDTO> in
                    if retryCount < 1, let networkError = error as? NetworkError, networkError.statusCode == 401 {
                        return self.refreshAccessToken().flatMap {
                            newAccessToken in
                            var newHeaders = headers
                            newHeaders["Authorization"] = newAccessToken
                            LoggerService.shared.log("AcessToken 재발급 : \(newAccessToken)")
                            return self.performRequest(url: url, headers: newHeaders, retryCount: retryCount + 1)
                        }
                    } else {
                        LoggerService.shared.log("AcessToken 재발급 실패", level: .error)
                        return Observable.error(error)
                    }
                }
        
    }
}
