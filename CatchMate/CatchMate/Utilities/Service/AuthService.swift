//
//  AuthService.swift
//  CatchMate
//
//  Created by 방유빈 on 8/1/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

enum AuthError: LocalizedError {
    case notFoundURL
    case serverError(code: Int, description: String)
    case decodingError
    case notFoundTokenInKeyChain
    
    
    var statusCode: Int {
        switch self {
        case .notFoundURL:
            return -1001
        case .serverError(let code, _):
            return code
        case .decodingError:
            return -1002
        case .notFoundTokenInKeyChain:
            return -1003
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .notFoundURL:
            return "서버 URL을 찾을 수 없습니다."
        case .serverError(_, let message):
            return "서버 에러: \(message)"
        case .decodingError:
            return "데이터 디코딩 에러"
        case .notFoundTokenInKeyChain:
            return "키체인에서 토큰을 가져올 수 없음"
        }
    }
}
final class AuthManager {
    static let shared = AuthManager()
    private let disposeBag = DisposeBag()
    private init() {}
    
    func attemptAutoLogin() -> Observable<Bool> {
        guard let base = Bundle.main.baseURL else {
            return Observable.error(AuthError.notFoundURL)
        }
        
        guard let refreshToken = KeychainService.getToken(for: .refreshToken), let accessToken = KeychainService.getToken(for: .accessToken) else {
            return Observable.error(AuthError.notFoundTokenInKeyChain)
        }
        
        return performRequest(base: base, refreshToken: refreshToken, accessToken: accessToken)
            .catch { error in
                LoggerService.shared.debugLog("자동 로그인 에러: - \(error)")
                return Observable.just(false)
            }
    }
    private func performRequest(base: String, refreshToken: String, accessToken: String) -> Observable<Bool> {
        let url = base + "/user/profile"
        let headers: HTTPHeaders = [
            "AccessToken": accessToken
        ]
        return RxAlamofire.requestData(.get, url, encoding: JSONEncoding.default, headers: headers)
            .flatMap { (response, data) -> Observable<Bool> in
                guard 200..<300 ~= response.statusCode else {
                    print(response.statusCode)
                    print(response.debugDescription)
                    if response.statusCode == 401 {
                        return Observable.error(AuthError.serverError(code: response.statusCode, description: "401 Error"))
                    }
                    return Observable.error(AuthError.serverError(code: response.statusCode, description: "서버에러 발생"))
                }
                
                return Observable.just(true)
            }
            .catch { error -> Observable<Bool> in
                if let userError = error as? AuthError, userError.statusCode == 401 {
                    return self.refreshAccessToken(base: base, token: refreshToken).flatMap { newAccessToken in
                        KeychainService.saveToken(token: newAccessToken, for: .accessToken)
                        return Observable.just(true)
                    }
                } else {
                    return Observable.error(error)
                }
            }
        
    }
    
    func refreshAccessToken(base: String, token: String) -> Observable<String> {
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
                        return Observable.error(AuthError.decodingError)
                    }
                } else {
                    return Observable.error(AuthError.serverError(code: response.statusCode, description: "토큰 재발급 실패 - 서버에러"))
                }
            }
    }
}
