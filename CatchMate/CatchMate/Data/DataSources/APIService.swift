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
    /// 로그인
    case login = "/auth/login"
    /// 회원가입
    case signUp = "/user/additional-info"
    /// 게시글 저장
    case savePost = "/board/write"
    /// 게시글 리스트 /board/page/{pageNum}
    case postlist = "/board/page/"
    /// 게시글 조회 /board/{boardId}
    case loadPost = "/board/"
    /// 찜목록 조회 /board/likes
    case loadFavorite = "/board/likes"
    /// 알람 설정
    case setNotification = "/user/alarm"
    
    var apiName: String {
        switch self {
        case .login:
            return "로그인 API"
        case .signUp:
            return "회원가입 API"
        case .savePost:
            return "게시글 요청 API"
        case .postlist:
            return "게시글 리스트 불러오기 API"
        case .loadPost:
            return "게시글 리스트 로드 API"
        case .loadFavorite:
            return "찜목록 로드 API"
        case .setNotification:
            return "알람 설정 API"

        }
    }
    
    var requstType: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .signUp:
            return .post
        case .savePost:
            return .post
        case .setNotification:
            return .patch
        case .loadPost:
            return .get
        case .loadFavorite:
            return .get
        case .postlist:
            return .get
        }
    }
}

final class APIService {
    static var shared = APIService()
    
    private var baseURL = Bundle.main.baseURL
    private let disposeBag = DisposeBag()
    
    func requestAPI<T: Codable>(addEndPoint: String? = nil, type: Endpoint, parameters: [String: Any]?, headers: HTTPHeaders? = nil, encoding: any ParameterEncoding = URLEncoding.default, dataType: T.Type) -> Observable<T> {
        LoggerService.shared.debugLog("APIService: - Request: \(type.apiName)")
        guard let base = baseURL else {
            LoggerService.shared.log("base 찾기 실패", level: .error)
            return Observable.error(NetworkError.notFoundBaseURL)
        }
        var url = base + type.rawValue
        if let addEndPoint = addEndPoint {
            url += addEndPoint
        }
        return RxAlamofire.requestData(type.requstType, url, parameters: parameters, encoding: encoding, headers: headers)
            .flatMap { (response, data) -> Observable<T> in
                guard 200..<300 ~= response.statusCode else {
                    LoggerService.shared.debugLog("\(type.apiName) Error : \(response.statusCode) \(response.debugDescription)")
                    if 400..<500 ~= response.statusCode {
                        return Observable.error(NetworkError.clientError(statusCode: response.statusCode))
                    } else if 500..<600 ~= response.statusCode {
                        return Observable.error(NetworkError.serverError(statusCode: response.statusCode))
                    }
                    return Observable.error(NetworkError.unownedError(statusCode: response.statusCode))
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
                    return Observable.error(CodableError.decodingFailed)
                }
            }
            .catch { error in
                return Observable.error(error)
            }
    }
    
    private let session: Session = {
        let configuration = URLSessionConfiguration.default
        return Session(configuration: configuration)
    }()
    
    func requestVoidAPI(type: Endpoint, parameters: [String: Any]?, headers: HTTPHeaders? = nil, encoding: any ParameterEncoding = URLEncoding.default) -> Observable<Void> {
        LoggerService.shared.debugLog("APIService: - Request: \(type.apiName)")
        
        guard let base = baseURL else {
            LoggerService.shared.log("base 찾기 실패", level: .error)
            return Observable.error(NetworkError.notFoundBaseURL)
        }
        
        let url = base + type.rawValue
        return Observable<Void>.create { [weak self] observer in
            guard let self = self else {
                observer.onError(ReferenceError.notFoundSelf)
                return Disposables.create()
            }
            
            let request = self.session.request(
                url,
                method: type.requstType,
                parameters: parameters,
                encoding: encoding,
                headers: headers
            )
                .validate(statusCode: 200..<300)
                .responseDecodable(of: Empty.self, emptyResponseCodes: [200]) { response in
                    switch response.result {
                    case .success(let data):
                        observer.onNext(())
                        observer.onCompleted()
                    case .failure(let error):
                        LoggerService.shared.debugLog("Request failed: \(error)")
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func refreshAccessToken() -> RxSwift.Observable<String> {
        LoggerService.shared.debugLog("토큰 재발급 시작")
        guard let base = Bundle.main.baseURL else {
            LoggerService.shared.log("base 찾기 실패", level: .error)
            return Observable.error(NetworkError.notFoundBaseURL)
        }
        guard let token = KeychainService.getToken(for: .refreshToken) else {
            LoggerService.shared.log("\(TokenError.notFoundRefreshToken.errorDescription!)", level: .error)
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
                        LoggerService.shared.debugLog("토큰 재발급 성공: \(refreshResponse.accessToken)")
                        return Observable.just(refreshResponse.accessToken)
                    } catch {
                        LoggerService.shared.log("APIService - 토큰 재발급 : \(CodableError.decodingFailed.errorDescription!)", level: .error)
                        return Observable.error(CodableError.decodingFailed)
                    }
                } else {
                    LoggerService.shared.log("APIService - 토큰 재발급( 서버 에러 ): \(response.debugDescription)", level: .error)
                    switch response.statusCode {
                    case 400..<500:
                        return Observable.error(NetworkError.clientError(statusCode: response.statusCode))
                    case 500..<600:
                        return Observable.error(NetworkError.serverError(statusCode: response.statusCode))
                    default:
                        return Observable.error(NetworkError.unownedError(statusCode: response.statusCode))
                    }
                }
            }
    }
}
