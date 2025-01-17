//
//  ErrorMapper.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//

import Foundation

final class ErrorMapper {
    static func mapToPresentationError(_ error: Error) -> PresentationError {
        if let domainError = error as? DomainError {
            switch domainError.context {
            case .action:
                return .showToastMessage(message: domainError.message ?? "작업 도중 오류가 발생했습니다. 다시 시도해주세요.")
            case .pageLoad:
                return .showErrorPage
            case .tokenUnavailable:
                return .unauthorized
            }
        }
        // TODO: - Logging 추가
        // DomainError가 아닐 경우 -> 알 수 없는 에러
        return .showErrorPage
    }
}
