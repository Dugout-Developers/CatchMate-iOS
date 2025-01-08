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

enum Endpoint {
    /// 로그인
    case login
    /// 회원가입
    case signUp
    /// 게시글 저장
    case savePost
    /// 게시글 수정
    case editPost
    /// 게시글 리스트
    case postlist
    /// user 게시글 조회
    case userPostlist
    /// 게시글 조회
    case loadPost
    /// 게시글 끌어올리기
    case upPost
    /// 게시글 삭제
    case removePost
    /// 찜목록 조회
    case loadFavorite
    /// 찜 설정
    case setFavorite
    /// 찜삭제
    case deleteFavorite
    /// 알람 설정
    case setNotification
    
    /// 직관 신청
    case apply
    /// 직관 신청 취소
    case cancelApply
    /// 보낸 직관 신청 목록
    case sendApply
    /// 받은 직관 신청 목록
    case receivedApply
    /// 받은 직관 신청 전체 목록
    case receivedApplyAll
    /// 받은 직관 신청 미확인 갯수
    case receivedCount
    /// 직관 신청 수락
    case acceptApply
    /// 직관 신청 거절
    case rejectApply
    
    /// 내정보 조회
    case loadMyInfo
    /// 내정보 수정
    case editProfile
    
    /// 알림 리스트 조회
    case notificationList
    /// 알림 삭제
    case deleteNoti
    
    var endPoint: String {
        switch self {
        case .login:
            return "/auth/login"
        case .signUp:
            return "/user/additional-info"
        case .savePost:
            return "/board"
        case .editPost:
            return "/board/"
        case .postlist:
            return "/board/list"
        case .userPostlist:
            return "/board/list/"
        case .loadPost:
            /// 게시글 조회 /board/{boardId}
            return "/board/"
        case .upPost:
            /// 끌어올리기 /board/{boardId}/lift-up
            return "/board/"
        case .removePost:
            return "/board/remove"
        case .loadFavorite:
            return "/board/bookmark"
        case .setFavorite, .deleteFavorite:
            /// 찜 설정 /board/bookmark/{boardID}
            return "/board/bookmark/"
        case .setNotification:
            return "/user/alarm"
        case .apply:
            /// 직관 신청 /enroll/{boardId}
            return "/enroll/"
        case .cancelApply:
            return "/enroll/cancel/"
        case .sendApply:
            return "/enroll/request"
        case .receivedApply:
            return "/enroll/receive"
        case .receivedApplyAll:
            return "/enroll/receive/all"
        case .receivedCount:
            return "/enroll/new-count"
        case .acceptApply, .rejectApply:
            /// acceptApply = /enroll/{enrollId}/accept
            /// rejectApply = /enroll/{enrollId}/reject
            return "/enroll/"
        case .loadMyInfo:
            return "/user/profile"
        case .editProfile:
            return "/user/profile"
        case .notificationList:
            return "/notification/receive"
        case .deleteNoti:
            return "/notification/receive/"
        }
    }
    var apiName: String {
        switch self {
        case .login:
            return "로그인 API"
        case .signUp:
            return "회원가입 API"
        case .savePost:
            return "게시글 저장 API"
        case .editPost:
            return "게시글 수정 API"
        case .postlist:
            return "게시글 리스트 불러오기 API"
        case .loadPost:
            return "게시글 로드 API"
        case .upPost:
            return "게시글 끌어올리기 API"
        case .removePost:
            return "게시글 삭제 API"
        case .userPostlist:
            return "유저 게시글 리스트 로드 API"
        case .loadFavorite:
            return "찜목록 로드 API"
        case .setFavorite:
            return "찜하기 API"
        case .deleteFavorite:
            return "찜 삭제 API"
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
        case .receivedCount:
            return "미확인 받은 신청 개수 API"
        case .acceptApply:
            return "직관 신청 수락 API"
        case .rejectApply:
            return "직관 신청 거절 API"
        case .loadMyInfo:
            return "내 정보 조회 API"
        case .editProfile:
            return "내 정보 수정 API"
        case .notificationList:
            return "알림 리스트 조회 API"
        case .deleteNoti:
            return "받은 알림 삭제 API"
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
        case .editPost:
            return .patch
        case .setNotification:
            return .patch
        case .loadPost:
            return .get
        case .upPost:
            return .patch
        case .removePost:
            return .delete
        case .userPostlist:
            return .get
        case .loadFavorite:
            return .get
        case .setFavorite:
            return .post
        case .deleteFavorite:
            return .delete
        case .postlist:
            return .get
        case .apply:
            return .post
        case .cancelApply:
            return .delete
        case .sendApply:
            return .get
        case .receivedApply:
            return .get
        case .receivedApplyAll:
            return .get
        case .receivedCount:
            return .get
        case .acceptApply:
            return .patch
        case .rejectApply:
            return .patch
        case .loadMyInfo:
            return .get
        case .editProfile:
            return .patch
        case .notificationList:
            return .get
        case .deleteNoti:
            return .delete
        }
    }
}

final class APIService {
    static var shared = APIService()
    
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
    
    func requestAPI<T: Codable>(addEndPoint: String? = nil, type: Endpoint, parameters: [String: Any]?, headers: HTTPHeaders? = nil, encoding: any ParameterEncoding = URLEncoding.default, dataType: T.Type) -> Observable<T> {
        LoggerService.shared.debugLog("APIService: - Request: \(type.apiName)")
        guard let base = baseURL else {
            LoggerService.shared.log("base 찾기 실패", level: .error)
            return Observable.error(NetworkError.notFoundBaseURL)
        }
        var url = base + type.endPoint
        if let addEndPoint = addEndPoint {
            url += addEndPoint
        }

        return RxAlamofire.requestData(type.requstType, url, parameters: parameters, encoding: encoding, headers: headers)
            .flatMap { [weak self] (response, data) -> Observable<T> in
                LoggerService.shared.debugLog("Request URL: \(String(describing: response.url))")
                guard let self = self else { return Observable.error(OtherError.notFoundSelf) }
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
        
        var url = base + type.endPoint
        if let addEndPoint = addEndPoint {
            url += addEndPoint
        }
        return Observable<Void>.create { [weak self] observer in
            guard let self = self else {
                observer.onError(OtherError.notFoundSelf)
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
