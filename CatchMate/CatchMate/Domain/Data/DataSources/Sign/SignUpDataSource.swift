//
//  SignUpDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 7/23/24.
//

import RxSwift
import RxAlamofire
import Alamofire
import UIKit

protocol SignUpDataSource {
    func saveUserModel(_ model: SignUpModel) -> Observable<Result<SignUpResponseDTO, SignUpAPIError>>
}
enum SignUpAPIError: Error {
    case notFoundURL
    case serverError(code: Int, description: String)
    case decodingError
    case unauthorized
    
    
    var statusCode: Int {
        switch self {
        case .notFoundURL:
            return -1001
        case .serverError(let code, _):
            return code
        case .decodingError:
            return -1002
        case .unauthorized:
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
        case .unauthorized:
            return "토큰이 유효하지않음"
        }
    }
}



final class SignUpDataSourceImpl: SignUpDataSource {
    func saveUserModel(_ model: SignUpModel) -> Observable<Result<SignUpResponseDTO, SignUpAPIError>> {
        guard let base = Bundle.main.baseURL else {
            return Observable.just(.failure(SignUpAPIError.notFoundURL))
        }
        
        let url = base + "/user/additional-info"
        let parameters: [String: Any] = [
            "nickName": model.nickName,
            "birthDate": model.birth,
            "favGudan": model.team.rawValue,
            "gender": model.gender.serverRequest,
            "watchStyle": model.cheerStyle?.rawValue ?? ""
        ]
        
        let headers: HTTPHeaders = [
            "AccessToken": model.accessToken
        ]
        
        return performRequest(url: url, parameters: parameters, headers: headers, model: model, retryCount: 0)
    }
}
    
    private func performRequest(url: String, parameters: [String: Any], headers: HTTPHeaders, model: SignUpModel, retryCount: Int) -> Observable<Result<SignUpResponseDTO, SignUpAPIError>> {
        do {
            print("Headers: \(headers)")
            print("parameter 출력 ")
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Encoded Parameters: \(jsonString)")
            }
            print("============")
        } catch {
            print("Failed to encode parameters: \(error)")
        }
        return RxAlamofire.requestData(.patch, url, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .flatMap { (response, data) -> Observable<Result<SignUpResponseDTO, SignUpAPIError>> in
                guard 200..<300 ~= response.statusCode else {
                    print(response.statusCode)
                    print(response.debugDescription)
                    if let errorData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = errorData["errorMessage"] as? String {
                        print(errorMessage)
                    }
                    if response.statusCode == 401 {
                        return Observable.just(.failure(SignUpAPIError.unauthorized))
                    }
                    return Observable.error(SignUpAPIError.serverError(code: response.statusCode, description: "서버에러 발생"))
                }
                
                do {
                    let signUpResponse = try JSONDecoder().decode(SignUpResponseDTO.self, from: data)
                    return Observable.just(.success(signUpResponse))
                } catch {
                    return Observable.just(.failure(SignUpAPIError.decodingError))
                }
            }
            .flatMap { result -> Observable<Result<SignUpResponseDTO, SignUpAPIError>> in
                switch result {
                case .success:
                    return Observable.just(result)
                case .failure(let error):
                    if case .unauthorized = error, retryCount < 1 {
                        return refreshAccessToken(model: model)
                            .flatMap { newAccessToken -> Observable<Result<SignUpResponseDTO, SignUpAPIError>> in
                                let newModel = SignUpModel(accessToken: newAccessToken, refreshToken: model.accessToken, nickName: model.nickName, birth: model.birth, team: model.team, gender: model.gender, cheerStyle: model.cheerStyle)
                                let updatedHeaders: HTTPHeaders = [
                                    "AccessToken": newAccessToken
                                ]
                                return performRequest(url: url, parameters: parameters, headers: updatedHeaders, model: newModel, retryCount: retryCount + 1)
                            }
                    } else {
                        return Observable.just(result)
                    }
                }
            }
    }
    
private func refreshAccessToken(model: SignUpModel) -> Observable<String> {
    guard let base = Bundle.main.baseURL else {
        return Observable.error(SignUpAPIError.notFoundURL)
    }
    
    let url = base + "/auth/reissue"
    let headers: HTTPHeaders = [
        "RefreshToken": model.refreshToken
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



