//
//  ErrorMapper.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//

import Foundation

final class ErrorMapper {
    static func mapToPresentationError(_ error: Error) -> PresentationError {
        if let networkError = error as? NetworkError {
            return mapNetworkError(networkError)
        } else if let mappingError = error as? MappingError {
            return mapMappingError(mappingError)
        } else if let codableError = error as? CodableError {
            return mapCodableError(codableError)
        } else if error is TokenError {
            return .unauthorized
        } else if let loginError = error as? SNSLoginError {
            return mapSNSLoginError(loginError)
        }
        // 다른 에러 타입 추가 가능
        return .showErrorPage
    }
    
    private static func mapMappingError(_ error: MappingError) -> PresentationError {
        switch error {
        case .mappingFailed:
            LoggerService.shared.debugLog("데이터 처리 오류가 발생")
            return .showErrorPage
        case .invalidData:
            return .showErrorPage
        }
    }
    
    private static func mapCodableError(_ error: CodableError) -> PresentationError {
        switch error {
        case .decodingFailed:
            return .showErrorPage
        case .encodingFailed:
            return .showToastMessage(message: "요청에 실패했습니다. 잠시 후 다시 시도해 주세요.")
        case .missingFields:
            return .showToastMessage(message: "누락된 입력값이 있습니다. 확인 후 다시 시도해주세요.")
        }
    }
    private static func mapNetworkError(_ error: NetworkError) -> PresentationError {
        switch error {
        case .notFoundBaseURL:
            return .showToastMessage(message: "예기치 않은 오류가 발생했습니다. 지원팀에 문의해주세요.")
        case .disconnected, .slowConnection, .responseTimeout:
            return .showToastMessage(message: "네트워크로 인해 요청이 지연되고 있습니다. 다시 시도해주세요.")
        case .serverUnavailable:
            return .showErrorPage
        case .unownedError(_):
            return .showErrorPage
        case .clientError(let statusCode):
            return mapClientError(statusCode)
        case .serverError(let statusCode):
            return mapServerError(statusCode)
        case .tokenRefreshFailed:
            return .unauthorized
        }
    }
    
    private static func mapClientError(_ statusCode: Int) -> PresentationError {
        switch statusCode {
        case 400:
            return .showToastMessage(message: "입력된 정보값을 확인 후 다시 시도해주세요")
        case 401:
            return .unauthorized
        case 403:
            return .showToastMessage(message: "해당 페이지에 액세스할 수 있는 권한이 없습니다.")
        case 404:
            return .showErrorPage
        default:
            return .showErrorPage
        }
    }
    
    private static func mapServerError(_ statusCode: Int) -> PresentationError {
        LoggerService.shared.debugLog("서버 오류 발생 Code: \(statusCode)")
        return .showErrorPage
    }
    
    private static func mapSNSLoginError(_ error: SNSLoginError) -> PresentationError {
        switch error {
        case .authorizationFailed:
            return .showToastMessage(message: "로그인 요청에 실패했습니다. 다시 시도해주세요.")
        case .EmptyValue:
            return .showToastMessage(message: "로그인 정보를 가져오는데 실패했습니다. 지원팀에 문의해주세요.")
        case .loginServerError(let code, _):
            switch code {
            case 400..<500:
                return mapClientError(code)
            case 500..<600:
                return mapServerError(code)
            default:
                return .showErrorPage
            }
        }
    }
    
    private static func mapTokenError(_ error: TokenError) -> PresentationError {
        switch error {
        case .notFoundAccessToken, .notFoundRefreshToken:
            return .unauthorized
        case .failureTokenService:
            return .showErrorPage
        case .failureSaveToken:
            return .unauthorized
        }
    }
    
    private static func mapOtherError(_ error: OtherError) -> PresentationError {
        switch error {
        case .invalidURL:
            return .showToastMessage(message: "다시 한 번 시도해주세요.")
        case .notFoundSelf:
            return .showErrorPage
        }
    }
}
