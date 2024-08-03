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

enum Endpoint: String {
    /// 게시글 저장
    case savePost = "/board/write"
    /// 게시글 리스트 /board/page/{pageNum}
    case postlist = "/board/page/"
    /// 게시글 조회 /board/{boardId}
    case loadPost = "/board/"
    /// 알람 설정
    case setNotification = "/user/alarm"
    
    var apiName: String {
        switch self {
        case .savePost:
            return "게시글 요청 API"
        case .postlist:
            return "게시글 리스트 불러오기 API"
        case .setNotification:
            return "알람 설정 API"
        case .loadPost:
            return "게시글 리스트 로드 API"
        }
    }
    
    var requstType: HTTPMethod {
        switch self {
        case .savePost:
            return .post
        case .setNotification:
            return .patch
        case .postlist:
            return .get
        case .loadPost:
            return .get
        }
    }
}
enum APIServiceError: LocalizedError {
    case notFoundURL
    case serverError(code: Int, description: String)
    case decodingError
    case notFoundAccessTokenInKeyChain
    case notFoundRefreshTokenInKeyChain
    
    var statusCode: Int {
        switch self {
        case .notFoundURL:
            return -1001
        case .serverError(let code, _):
            return code
        case .decodingError:
            return -1002
        case .notFoundAccessTokenInKeyChain:
            return -1003
        case .notFoundRefreshTokenInKeyChain:
            return -1004
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
        case .notFoundAccessTokenInKeyChain:
            return "키체인에서 엑세스 토큰을 가져올 수 없음"
        case .notFoundRefreshTokenInKeyChain:
            return "키체인에서 리프레시 토큰을 가져올 수 없음"
        }
    }
}

final class APIService {
    static var apiService = APIService()
    
    private var baseURL = Bundle.main.baseURL
    private let disposeBag = DisposeBag()
    
    func requestAPI<T: Codable>(type: Endpoint, parameters: [String: Any]?, headers: HTTPHeaders? = nil, encoding: any ParameterEncoding = URLEncoding.default, dataType: T.Type) -> Observable<T> {
        LoggerService.shared.debugLog("APIService: - Get Request: \(type.rawValue)")
        guard let base = baseURL else {
            LoggerService.shared.log("base 찾기 실패", level: .error)
            return Observable.error(APIServiceError.notFoundURL)
        }
        let url = base + type.rawValue
        
        return RxAlamofire.requestData(type.requstType, url, parameters: parameters, encoding: encoding, headers: headers)
            .flatMap { (response, data) -> Observable<T> in
                guard 200..<300 ~= response.statusCode else {
                    LoggerService.shared.debugLog("\(type.apiName) Error : \(response.statusCode) \(response.debugDescription)")
                    return Observable.error(APIServiceError.serverError(code: response.statusCode, description: "서버에러 발생"))
                }
                
                do {
                    let dtoResponse = try JSONDecoder().decode(T.self, from: data)
                    LoggerService.shared.log("DTO: \(dtoResponse)")
                    return Observable.just(dtoResponse)
                } catch {
                    LoggerService.shared.log("Decoding Error", level: .error)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        LoggerService.shared.debugLog("Decoding Error - JSON 데이터 : \(jsonString)")
                    } else {
                        LoggerService.shared.debugLog("Decoding Error: Json String 변환 불가")
                    }
                    return Observable.error(APIServiceError.decodingError)
                }
            }
    }
    
    func refreshAccessToken() -> RxSwift.Observable<String> {
        LoggerService.shared.debugLog("토큰 재발급 시작")
        guard let base = Bundle.main.baseURL else {
            LoggerService.shared.log("base 찾기 실패", level: .error)
            return Observable.error(APIServiceError.notFoundURL)
        }
        guard let token = KeychainService.getToken(for: .refreshToken) else {
            LoggerService.shared.log("\(APIServiceError.notFoundRefreshTokenInKeyChain.errorDescription!)", level: .error)
            return Observable.error(APIServiceError.notFoundRefreshTokenInKeyChain)
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
                        LoggerService.shared.debugLog("토큰 재발급 성공: \(refreshResponse.accessToken)")
                        return Observable.just(refreshResponse.accessToken)
                    } catch {
                        LoggerService.shared.log("APIService - 토큰 재발급 : \(APIServiceError.decodingError.errorDescription!)", level: .error)
                        return Observable.error(APIServiceError.decodingError)
                    }
                } else {
                    LoggerService.shared.log("APIService - 토큰 재발급( 서버 에러 ): \(response.debugDescription)", level: .error)
                    return Observable.error(APIServiceError.serverError(code:  response.statusCode, description: "토큰 재발급 실패 - 서버에러"))
                }
            }
    }
}
