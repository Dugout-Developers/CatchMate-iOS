//
//  NicknameCheckDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 7/30/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol NicknameCheckDataSource {
    func checkNickname(_ nickname: String) -> Observable<Bool>
}
enum NicknameAPIError: Error {
    case notFoundURL
    case serverError(code: Int, description: String)
    case decodingError
    
    
    var statusCode: Int {
        switch self {
        case .notFoundURL:
            return -1001
        case .serverError(let code, _):
            return code
        case .decodingError:
            return -1002
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
        }
    }
}
final class NicknameCheckDataSourceImpl: NicknameCheckDataSource {
    func checkNickname(_ nickname: String) -> RxSwift.Observable<Bool> {
        guard let base = Bundle.main.baseURL else {
            return Observable.error(NicknameAPIError.notFoundURL)
        }
        let url = base + "/auth/check-nickname"
        let parameters: [String: Any] = [
            "nickname": nickname
        ]
        return RxAlamofire.requestData(.get, url, parameters: parameters, encoding: JSONEncoding.default)
            .flatMap { (response, data) -> Observable<Bool> in
                guard 200..<300 ~= response.statusCode else {
                    print(response.statusCode)
                    print(response.debugDescription)
                    if let errorData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = errorData["errorMessage"] as? String {
                        print(errorMessage)
                    }
                    return Observable.error(NicknameAPIError.serverError(code: response.statusCode, description: "서버에러 발생"))
                }
                
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let available = jsonObject["available"] as? Bool {
                        return Observable.just(available)
                    } else {
                        return Observable.error(NicknameAPIError.decodingError)
                    }
                } catch {
                    // JSON 데이터를 문자열로 변환하여 출력
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Decoding Error: JSON 데이터는 다음과 같습니다.")
                        print(jsonString)
                    } else {
                        print("Decoding Error: JSON 데이터를 문자열로 변환할 수 없습니다.")
                    }
                    return Observable.error(UserAPIError.decodingError)
                }
            }
    }
    
    
}

