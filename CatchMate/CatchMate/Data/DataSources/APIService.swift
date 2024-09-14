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
    /// 찜 설정 /board/like/{boardID}
    case setFavorite = "/board/like/"
    /// 알람 설정
    case setNotification = "/user/alarm"
    
    /// 직관 신청 /enroll/{boardId}
    case apply = "/enroll/"
    /// 직관 신청 취소 /enroll/cancel/{enrollId}
    case cancelApply = "/enroll/cancel/"
    /// 보낸 직관 신청 목록
    case sendApply = "/enroll/request"
    /// 받은 직관 신청 목록
    case receivedApply = "/enroll/receive"
    /// 받은 직관 신청 전체 목록
    case receivedApplyAll = "/enroll/receive/all"
    
    /// 내정보 조회
    case loadMyInfo = "/user/profile"
    
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
            return "게시글 로드 API"
        case .loadFavorite:
            return "찜목록 로드 API"
        case .setFavorite:
            return "찜 상태 설정 API"
        case .setNotification:
            return "알람 설정 API"
        case .apply:
            return "직관 신청 API"
        case .cancelApply:
            return "직관 신청 취소 API"
        case .sendApply:
            return "보낸 신청 목록 API"
        case .receivedApply:
            return "받은 신청 목록 API"
        case .receivedApplyAll:
            return "받은 신청 전체 목록 API"
        case .loadMyInfo:
            return "내 정보 조회 API"
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
        case .setFavorite:
            return .post
        case .postlist:
            return .get
        case .apply:
            return .post
        case .cancelApply:
            return .post
        case .sendApply:
            return .get
        case .receivedApply:
            return .get
        case .receivedApplyAll:
            return .get
        case .loadMyInfo:
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
            .flatMap { [weak self] (response, data) -> Observable<T> in
                LoggerService.shared.debugLog("Request URL: \(response.url)")
                guard let self = self else { return Observable.error(ReferenceError.notFoundSelf) }
                guard 200..<300 ~= response.statusCode else {
                    LoggerService.shared.debugLog("\(type.apiName) Error : \(response.statusCode) \(response.debugDescription)")
                    return Observable.error(mapServerError(statusCode: response.statusCode))
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
    
    func requestVoidAPI(addEndPoint: String? = nil, type: Endpoint, parameters: [String: Any]?, headers: HTTPHeaders? = nil, encoding: any ParameterEncoding = URLEncoding.default) -> Observable<Void> {
        LoggerService.shared.debugLog("APIService: - Request: \(type.apiName)")
        
        guard let base = baseURL else {
            LoggerService.shared.log("base 찾기 실패", level: .error)
            return Observable.error(NetworkError.notFoundBaseURL)
        }
        
        var url = base + type.rawValue
        if let addEndPoint = addEndPoint {
            url += addEndPoint
        }
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
                        print(data)
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
    
    func refreshAccessToken(refreshToken: String) -> RxSwift.Observable<String> {
        LoggerService.shared.debugLog("토큰 재발급 시작")
        guard let base = Bundle.main.baseURL else {
            LoggerService.shared.log("base 찾기 실패", level: .error)
            return Observable.error(NetworkError.notFoundBaseURL)
        }

        LoggerService.shared.debugLog("Refresh Token: \(refreshToken)")
        let url = base + "/auth/reissue"
        let headers: HTTPHeaders = [
            "RefreshToken": refreshToken
        ]
        return RxAlamofire.requestJSON(.post, url, encoding: JSONEncoding.default, headers: headers)
            .flatMap { (response, data) -> Observable<String> in
                if response.statusCode == 200 {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let refreshResponse = try JSONDecoder().decode(RefreshTokenResponseDTO.self, from: jsonData)
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
    
    func mapServerError(statusCode: Int) -> NetworkError {
        switch statusCode {
        case 400..<500:
            return .clientError(statusCode: statusCode)
        case 500..<600:
            return .serverError(statusCode: statusCode)
        default:
            return .unownedError(statusCode: statusCode)
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
