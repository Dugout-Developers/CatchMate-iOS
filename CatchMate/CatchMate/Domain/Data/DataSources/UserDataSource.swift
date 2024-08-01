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

enum UserAPIError: Error {
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

protocol UserDataSource {
    func refreshAccessToken() -> Observable<String>
    func loadMyInfo() -> Observable<UserDTO>
}
final class UserDataSourceImpl: UserDataSource {
    func refreshAccessToken() -> RxSwift.Observable<String> {
        guard let base = Bundle.main.baseURL else {
            return Observable.error(SignUpAPIError.notFoundURL)
        }
        guard let token = KeychainService.getToken(for: .refreshToken) else {
            return Observable.error(UserAPIError.notFoundTokenInKeyChain)
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
                        return Observable.error(SignUpAPIError.decodingError)
                    }
                } else {
                    return Observable.error(SignUpAPIError.serverError(code:  response.statusCode, description: "토큰 재발급 실패 - 서버에러"))
                }
            }
    }
    
    func loadMyInfo() -> RxSwift.Observable<UserDTO> {
        guard let base = Bundle.main.baseURL else {
            return Observable.error(UserAPIError.notFoundURL)
        }
        guard let token = KeychainService.getToken(for: .accessToken) else {
            return Observable.error(UserAPIError.notFoundTokenInKeyChain)
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
                        print(response.statusCode)
                        print(response.debugDescription)
                        if let errorData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let errorMessage = errorData["errorMessage"] as? String {
                            print(errorMessage)
                        }
                        if response.statusCode == 401 {
                            return Observable.error(UserAPIError.serverError(code: response.statusCode, description: "401 Error"))
                        }
                        return Observable.error(SignUpAPIError.serverError(code: response.statusCode, description: "서버에러 발생"))
                    }
                    
                    do {
                        let userResponse = try JSONDecoder().decode(UserDTO.self, from: data)
                        return Observable.just(userResponse)
                    } catch {
                        if let jsonString = String(data: data, encoding: .utf8) {
                                            print("Decoding Error: JSON 데이터는 다음과 같습니다.")
                                            print(jsonString)
                                        } else {
                                            print("Decoding Error: JSON 데이터를 문자열로 변환할 수 없습니다.")
                                        }
                        return Observable.error(UserAPIError.decodingError)
                    }
                }
                .catch { error -> Observable<UserDTO> in
                    if retryCount < 1, let userError = error as? UserAPIError, userError.statusCode == 401 {
                        return self.refreshAccessToken().flatMap { newAccessToken in
                            var newHeaders = headers
                            newHeaders["Authorization"] = newAccessToken
                            return self.performRequest(url: url, headers: newHeaders, retryCount: retryCount + 1)
                        }
                    } else {
                        return Observable.error(error)
                    }
                }
        
    }
}
