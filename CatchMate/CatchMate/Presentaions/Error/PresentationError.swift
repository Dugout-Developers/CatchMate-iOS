//
//  PresentationError.swift
//  CatchMate
//
//  Created by 방유빈 on 8/6/24.
//

import Foundation

enum PresentationError: LocalizedError {
    case showErrorPage
    case showToastMessage(message: String)
    case unauthorized     // 인증 실패
}
