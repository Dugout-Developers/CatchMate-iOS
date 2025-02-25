//
//  APIService.swift
//  CatchMate
//
//  Created by 방유빈 on 8/3/24.
//
import UIKit
import RxSwift
import RxAlamofire
import Alamofire

final class APIService {
    static var shared = APIService()
    
    private let maxRetryCount = 1
    private var baseURL = Bundle.main.baseURL
    private let disposeBag = DisposeBag()
    
    func convertToDictionary<T: Encodable>(_ encodable: T) -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(encodable)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            return jsonObject as? [String: Any]
        } catch {
            print("JSON 변환 실패: \(error)")
            return nil
        }
    }
    
    func performRequest<T: Codable>(retry: Int = 0, addEndPoint: String? = nil, type: Endpoint, parameters: [String: Any]?, headers: HTTPHeaders?, encoding: any ParameterEncoding, dataType: T.Type, refreshToken: String?) -> Observable<T> {
        if retry > maxRetryCount {
            LoggerService.shared.log(level: .debug, "APIService - 토큰 재발급 횟수 초과")
            return Observable.error(TokenError.invalidToken)
        }
        
        return requestAPI(addEndPoint: addEndPoint, type: type, parameters: parameters, headers: headers, encoding: encoding, dataType: dataType)
            .timeout(.seconds(10), scheduler: MainScheduler.instance)
            .catch { [weak self] error in
                guard let self = self else {
                    return Observable.error(OtherError.notFoundSelf(location: "APIService-performRequest"))
                }
                if let rxError = error as? RxError, case .timeout = rxError {
                    LoggerService.shared.log(level: .error, "APIService - 요청이 타임아웃됨. (10초 초과)")
                    return Observable.error(NetworkError.responseTimeout)
                }
                
                if let networkError = error as? NetworkError, networkError.statusCode == 401 {
                    guard let refreshToken else {
                        LoggerService.shared.log(level: .debug, "APIService - 리프레시 토큰 찾을 수 없음")
                        return Observable.error(TokenError.notFoundRefreshToken)
                    }
                    return refreshAccessToken(refreshToken: refreshToken)
                        .withUnretained(self)
                        .flatMap { service, newToken -> Observable<T> in
                            var newHeaders = headers ?? HTTPHeaders()
                            newHeaders["AccessToken"] = newToken
                            return service.performRequest(retry: retry+1, addEndPoint: addEndPoint, type: type, parameters: parameters, headers: newHeaders, encoding: encoding, dataType: dataType, refreshToken: refreshToken)
                        }
                }
                
                return Observable.error(error)
            }
    }
    
    func requestAPI<T: Codable>(addEndPoint: String? = nil, type: Endpoint, parameters: [String: Any]?, headers: HTTPHeaders? = nil, encoding: any ParameterEncoding = URLEncoding.default, dataType: T.Type) -> Observable<T> {
        LoggerService.shared.log(level: .debug, "APIService: - Request: \(type.apiName)")
        guard let base = baseURL else {
            LoggerService.shared.log(level: .debug, "Base URL 찾을 수 없음")
            return Observable.error(NetworkError.notFoundBaseURL)
        }
        var url = base + type.endPoint
        if let addEndPoint = addEndPoint {
            url += addEndPoint
        }
        LoggerService.shared.log("요청 URL: \(url)")

        return RxAlamofire.requestData(type.requstType, url, parameters: parameters, encoding: encoding, headers: headers)
            .flatMap { [weak self] (response, data) -> Observable<T> in
                LoggerService.shared.log(level: .debug, "Request URL: \(String(describing: response.url))")
                guard self != nil else { return Observable.error(OtherError.notFoundSelf(location: "APIService-requestAPI")) }
                guard 200..<300 ~= response.statusCode else {
                    LoggerService.shared.log(level: .debug, "\(type.apiName) Error : \(response.statusCode) \(response.debugDescription)")
                    return Observable.error(NetworkError(serverStatusCode: response.statusCode))
                }
                do {
                    let dtoResponse = try JSONDecoder().decode(T.self, from: data)
                    LoggerService.shared.log(level: .debug, "DTO: \(dtoResponse)")
                    return Observable.just(dtoResponse)
                } catch {
                    print(error.localizedDescription)
                    LoggerService.shared.log(level: .debug, "APIService - Decoding Error")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        LoggerService.shared.log(level: .debug, "Decoding Error - JSON 데이터 : \(jsonString)")
                    } else {
                        LoggerService.shared.log(level: .debug, "Decoding Error: Json String 변환 불가")
                    }
                    return Observable.error(CodableError.decodingFailed)
                }
            }
            .catch { error in
                return Observable.error(error)
            }
    }
    
    func refreshAccessToken(refreshToken: String) -> RxSwift.Observable<String> {
        LoggerService.shared.log(level: .info, "토큰 재발급 시작")
        guard let base = Bundle.main.baseURL else {
            LoggerService.shared.log(level: .debug, "Base URL 찾을 수 없음")
            return Observable.error(NetworkError.notFoundBaseURL)
        }

        LoggerService.shared.log(level: .debug, "Refresh Token: \(refreshToken)")
        let url = base + "/auth/reissue"
        let headers: HTTPHeaders = [
            "RefreshToken": refreshToken
        ]
        return RxAlamofire.requestJSON(.post, url, encoding: JSONEncoding.default, headers: headers)
            .flatMap { [weak self] (response, data) -> Observable<String> in
                guard self != nil else {
                    LoggerService.shared.log(level: .debug, "토큰 재발급 성공 Not Found Self")
                    return Observable.error(OtherError.notFoundSelf(location: "APIService - refreshAccessToken"))
                }
                if response.statusCode == 200 {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let refreshResponse = try JSONDecoder().decode(RefreshTokenResponseDTO.self, from: jsonData)
                        LoggerService.shared.log(level: .debug, "토큰 재발급 성공: \(refreshResponse.accessToken)")
                        return Observable.just(refreshResponse.accessToken)
                    } catch {
                        LoggerService.shared.log(level: .debug, "APIService - 토큰 재발급 : \(CodableError.decodingFailed.errorDescription!)")
                        return Observable.error(CodableError.decodingFailed)
                    }
                } else {
                    LoggerService.shared.log(level: .debug, "APIService - 토큰 재발급( 서버 에러 ): \(response.debugDescription)")
                    return Observable.error(NetworkError(serverStatusCode: response.statusCode))
                }
            }
    }
}


struct CustomURLEncoding: ParameterEncoding {
    static var `default`: CustomURLEncoding { return CustomURLEncoding() }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        
        guard let url = urlRequest.url, var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return urlRequest
        }
        
        var newQueryItems = [URLQueryItem]()
        
        for queryItem in queryItems {
            if let value = queryItem.value, value.isEmpty {
                // 빈 값을 가진 항목이 있을 경우, 빈 값으로 인코딩
                newQueryItems.append(URLQueryItem(name: queryItem.name, value: ""))
            } else {
                newQueryItems.append(queryItem)
            }
        }
        
        components.queryItems = newQueryItems
        urlRequest.url = components.url
        return urlRequest
    }
}

