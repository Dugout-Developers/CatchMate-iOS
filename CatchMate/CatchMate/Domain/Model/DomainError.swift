//
//  DomainError.swift
//  CatchMate
//
//  Created by 방유빈 on 12/24/24.
//

/// DomainError -> 맥락 + Error
struct DomainError: Error {
    let error: Error
    let context: ErrorContext
    let message: String?
    
    init(error: Error, context: ErrorContext, message: String? = nil) {
        self.error = error
        self.context = context
        self.message = message
    }
}

/// Presentation Error 발생 상황 맥락
enum ErrorContext {
    case action
    case pageLoad
    case tokenUnavailable
}

extension DomainError {
    func toPresentationError() -> PresentationError {
        let message = self.message
        switch context {
        case .action:
            if let message {
                return .showToastMessage(message: message)
            } else {
                return .showToastMessage(message: "오류가 발생했습니다. 다시 시도해주세요.")
            }
        case .pageLoad:
            return .showErrorPage
        case .tokenUnavailable:
            return .unauthorized
        }
    }
}
