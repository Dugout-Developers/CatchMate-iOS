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
    case requestFailed
    
    
    var statusCode: Int {
        switch self {
        case .notFoundURL:
            return -1001
        case .serverError(let code, _):
            return code
        case .decodingError:
            return -1002
        case .requestFailed:
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
        case .requestFailed:
            return "요청 실패"
        }
    }
}


final class NicknameCheckDataSourceImpl: NicknameCheckDataSource {
    func checkNickname(_ nickname: String) -> RxSwift.Observable<Bool> {
        guard let base = Bundle.main.baseURL else {
            return Observable.error(NicknameAPIError.notFoundURL)
        }
        let url = base + "/auth/check-nickname"
        let urlString = url + "?" + "nickName=\(nickname)"

        return RxAlamofire.requestJSON(.get, urlString)
            .do(onNext: { (response, json) in
                // 응답 상태 코드 및 데이터 출력
                print("Response Status Code: \(response.statusCode)")
                print(json)
            }, onError: { error in
                // 에러 발생 시 로그 출력
                print("Network Request Error: \(error)")
            })
            .flatMap { (response, json) -> Observable<Bool> in
                guard 200...300 ~= response.statusCode else {
                    print(response.statusCode)
                    print(response.debugDescription)
                    return Observable.error(NicknameAPIError.serverError(code: response.statusCode, description: "서버에러 발생"))
                }
                
                if let jsonDict = json as? [String: Any], let result = jsonDict["available"] as? Bool {
                    return Observable.just(result)
                } else {
                    return Observable.error(NicknameAPIError.decodingError)
                }
            }
    }
    
    func encodeParameters(parameters: [String: Any]) -> String {
        var components = URLComponents()
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: "\(value)")
        }
        return components.percentEncodedQuery ?? ""
    }
}



