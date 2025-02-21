//
//  DataError.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//

import Foundation

// Token KeyChain 관련 Error
enum TokenError: LocalizedErrorWithCode {
    case notFoundAccessToken
    case notFoundRefreshToken
    case failureSaveToken
    case failureTokenService
    case invalidToken
    
    var statusCode: Int {
        switch self {
        case .notFoundAccessToken:
            return -1001
        case .notFoundRefreshToken:
            return -1002
        case .failureSaveToken:
            return -1003
        case .failureTokenService:
            return -1004
        case .invalidToken:
            return -1005
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .notFoundAccessToken:
            return "엑세스 토큰 찾기 실패"
        case .notFoundRefreshToken:
            return "리프레시 토큰 찾기 실패"
        case .failureSaveToken:
            return "토큰 저장 실패"
        case .failureTokenService:
            return "토큰 서비스 실행 실패"
        case .invalidToken:
            return "유효하지 않은 토큰"
        }
    }
}

// 네트워크 에러
enum NetworkError: LocalizedErrorWithCode {
    case notFoundBaseURL
    case disconnected
    case responseTimeout
    case clientError(statusCode: Int) // 4xx 에러
    case serverError(statusCode: Int) // 5xx 에러
    case unownedError(statusCode: Int)
    
    init(serverStatusCode: Int) {
        switch serverStatusCode {
        case 400..<500:
            self = .clientError(statusCode: serverStatusCode)
        case 500..<600:
            self = .serverError(statusCode: serverStatusCode)
        default:
            self = .unownedError(statusCode: serverStatusCode)
        }
    }
    var statusCode: Int {
        switch self {
        case .notFoundBaseURL:
            return -2000
        case .disconnected:
            return -2001
        case .responseTimeout:
            return -2002
        case .unownedError(let statusCode):
            return statusCode
        case .clientError(let statusCode):
            return statusCode
        case .serverError(let statusCode):
            return statusCode
        }
    }
    var errorDescription: String? {
        switch self {
        case .notFoundBaseURL:
            return "베이스 URL을 찾을 수 없음"
        case .disconnected:
            return "사용자 네트워크 연결 실패"
        case .responseTimeout:
            return "사용자 타임 아웃"       
        case .clientError(let statusCode):
            return "클라이언트 요청 에러: \(statusCode)"
        case .serverError(let statusCode):
            return "서버 에러: \(statusCode)"
        case .unownedError(let statusCode):
            return "그 외 API Error: \(statusCode)"
        }
    }
}

// 매핑 에러
enum MappingError: LocalizedErrorWithCode {
    ///DomainModel -> DTO
    case mappingFailed
    ///DTO -> DomainModel
    case invalidData
    case stateFalse
    
    var statusCode: Int {
        switch self {
        case .mappingFailed:
            return -3001
        case .invalidData:
            return -3002
        case .stateFalse:
            return -3003
        }
    }
    var errorDescription: String? {
        switch self {
        case .mappingFailed:
            return "DomainModel -> DTO 매핑 실패"
        case .invalidData:
            return "DTO -> DomainModel 매핑 실패"
        case .stateFalse:
            return "state 반환값 false"
        }
    }
}

// 데이터 변환 에러
enum CodableError: LocalizedErrorWithCode {
    case decodingFailed
    case encodingFailed
    case missingFields
    case emptyValue(String)
    
    var statusCode: Int {
        switch self {
        case .decodingFailed:
            return -4001
        case .encodingFailed:
            return -4002
        case .missingFields:
            return -4003
        case .emptyValue:
            return -4004
        }
    }
    var errorDescription: String? {
        switch self {
        case .decodingFailed:
            return "응답 데이터 디코딩 실패"
        case .encodingFailed:
            return "요청 데이터 인코딩 실패"
        case .missingFields:
            return "요청 필드 누락"
        case .emptyValue(let description):
            return "응답 필드 찾기 실패: \(description)"
        }
    }
}

// SNS Login 관련 Error
enum SNSLoginError: LocalizedErrorWithCode {
    case authorizationFailed
    case emptyValue(description: String)
    case loginServerError(message: String)


    var statusCode: Int {
        switch self {
        case .authorizationFailed:
            return -5001
        case .emptyValue:
            return -5002
        case .loginServerError:
            return -5000
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .authorizationFailed:
            return "권한 부여 실패 - 토큰 없음"
        case .emptyValue(let description):
            return "빈 응답값 전달: \(description)"
        case .loginServerError(let message):
            return "서버 에러: \(message)"
        }
    }
}

enum OtherError: LocalizedErrorWithCode {
    case invalidURL(location: String)
    case notFoundSelf(location: String)
    case failureTypeCase
    
    var statusCode: Int {
        switch self {
        case .invalidURL:
            return -6001
        case .notFoundSelf:
            return -6002
        case .failureTypeCase:
            return -6003
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidURL(let location):
            return "\(location) - URL 형식이 잘못되었습니다."
        case .notFoundSelf(let location):
            return "\(location) - self 참조 실패"
        case .failureTypeCase:
            return "타입 캐스팅 실패"
        }
    }
}
