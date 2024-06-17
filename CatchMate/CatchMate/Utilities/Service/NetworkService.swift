//
//  NetworkService.swift
//  CatchMate
//
//  Created by 방유빈 on 6/17/24.
//

import UIKit
import RxSwift
import RxAlamofire

enum Endpoint: String {
    case getPosting = ""
}

enum APIError: Error {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case invalidDate
}

final class APIService {
    static var apiService = APIService()
    
    private var baseURL = Bundle.main.baseURL
    private let disposeBag = DisposeBag()
    
    func returnURLString(type: Endpoint) -> String {
        guard let baseURL = baseURL else { return "" }
        return baseURL + type.rawValue
    }
    
    func getAPI<T: Codable>(type: Endpoint, parameters: [String: Any], dataType: T.Type) -> Observable<T> {
        let urlString = returnURLString(type: type)
                guard let url = URL(string: urlString) else {
                    return Observable.error(APIError.invalidURL)
                }
        return RxAlamofire.requestDecodable(.get, url, parameters: parameters)
            .flatMap { (response: HTTPURLResponse, data: T) -> Observable<T> in
                if (200..<300).contains(response.statusCode) {
                    print(data)
                    return Observable.just(data)
                } else {
                    return Observable.error(APIError.invalidResponse(statusCode: response.statusCode))
                }
            }
    }
    
    func postAPI<T: Codable>(type: Endpoint, parameters: [String: Any], dataType: T.Type) -> Observable<T> {
        let urlString = returnURLString(type: type)
                guard let url = URL(string: urlString) else {
                    return Observable.error(APIError.invalidURL)
                }
        return RxAlamofire.requestDecodable(.post, url, parameters: parameters)
            .flatMap { (response: HTTPURLResponse, data: T) -> Observable<T> in
                if (200..<300).contains(response.statusCode) {
                    print(data)
                    return Observable.just(data)
                } else {
                    return Observable.error(APIError.invalidResponse(statusCode: response.statusCode))
                }
            }
    }
}

