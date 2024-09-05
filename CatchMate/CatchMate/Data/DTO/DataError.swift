//
//  DataError.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//

import Foundation

// 네트워크 에러
enum NetworkError: LocalizedError {
    case notFoundBaseURL
    case disconnected
    case slowConnection
    case responseTimeout
    case serverUnavailable
    case tokenRefreshFailed
    case clientError(statusCode: Int) // 4xx 에러
    case serverError(statusCode: Int) // 5xx 에러
    case unownedError(statusCode: Int)
    
    var statusCode: Int {
        switch self {
        case .notFoundBaseURL:
            return -2000
        case .disconnected:
            return -2001
        case .slowConnection:
            return -2002
        case .responseTimeout:
            return -2003
        case .serverUnavailable:
            return -2004
        case .tokenRefreshFailed:
            return -2005
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
        case .slowConnection:
            return "사용자 네트워크 속도 문제로 인한 응답 지연"
        case .responseTimeout:
            return "사용자 타임 아웃"       
        case .serverUnavailable:
            return "서버 이용 불가능"
        case .tokenRefreshFailed:
            return "토큰 재발급 실패"
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
enum MappingError: LocalizedError {
    ///DomainModel -> DTO
    case mappingFailed
    ///DTO -> DomainModel
    case invalidData
    
    var statusCode: Int {
        switch self {
        case .mappingFailed:
            return -3001
        case .invalidData:
            return -3002
        }
    }
    var errorDescription: String? {
        switch self {
        case .mappingFailed:
            return "DomainModel -> DTO 매핑 실패"
        case .invalidData:
            return "DTO -> DomainModel 매핑 실패"
        }
    }
}

// 디코딩 에러
enum CodableError: LocalizedError {
    case decodingFailed
    case encodingFailed
    case missingFields
    
    var statusCode: Int {
        switch self {
        case .decodingFailed:
            return -4001
        case .encodingFailed:
            return -4002
        case .missingFields:
            return -4003
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
        }
    }
}

enum ReferenceError: LocalizedError {
    case notFoundSelf
    var statusCode: Int {
        switch self {
        case .notFoundSelf:
            return -5001
        }
    }
    var errorDescription: String? {
        switch self {
        case .notFoundSelf:
            return "self 참조 실패"
        }
    }
}
// SNS Login 관련 Error
enum SNSLoginError: LocalizedError {
    case authorizationFailed
    case EmptyValue
    case loginServerError(code: Int, description: String)


    var statusCode: Int {
        switch self {
        case .authorizationFailed:
            return -1001
        case .EmptyValue:
            return -1003
        case .loginServerError(let code, _):
            return code
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .authorizationFailed:
            return "권한 부여 실패 - 토큰 없음"
        case .EmptyValue:
            return "빈 응답값 전달"
        case .loginServerError(_, let message):
            return "서버 에러: \(message)"
        }
    }
}

// Token KeyChain 관련 Error
enum TokenError: LocalizedError {
    case notFoundAccessToken
    case notFoundRefreshToken
    case failureTokenService
    
    var statusCode: Int {
        switch self {
        case .notFoundAccessToken:
            return -1001
        case .notFoundRefreshToken:
            return -1002
        case .failureTokenService:
            return -1003
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .notFoundAccessToken:
            return "엑세스 토큰 찾기 실패"
        case .notFoundRefreshToken:
            return "리프레시 토큰 찾기 실패"
        case .failureTokenService:
            return "토큰 서비스 실행 실패"
        }
    }
}
