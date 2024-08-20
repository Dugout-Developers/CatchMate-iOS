//
//  PresentationError.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//

import Foundation

enum PresentationError: LocalizedError {
    case retryable(message: String)         // 재시도 가능
    case contactSupport(message: String)    // 고객 지원 요청
    case showErrorPage(message: String)     // 에러 페이지 표시
    case informational(message: String)     // 정보성 메시지
    case validationFailed(message: String)  // 입력 값 검증 실패
    case unauthorized(message: String)      // 인증 실패
    case timeout(message: String)    // 시간 초과
    case unknown(message: String)
    var errorDescription: String? {
        switch self {
        case .retryable(let message),
             .contactSupport(let message),
             .showErrorPage(let message),
             .informational(let message),
             .validationFailed(let message),
             .unauthorized(let message),
             .timeout(let message),
             .unknown(let message):
            return message
        }
    }
}
