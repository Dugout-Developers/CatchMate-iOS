//
//  Error+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 8/1/24.
//
import Foundation

extension Error {
    var statusCode: Int {
        if let localizedError = self as? LocalizedError, let statusCode = (localizedError as? CustomNSError)?.errorCode {
            return statusCode
        }
        return -9999 // 기본값으로 -9999를 반환
    }

    var errorDescription: String? {
        return (self as? LocalizedError)?.errorDescription ?? "An unexpected error occurred.: \(self.localizedDescription)"
    }
}


extension LocalizedError {
    static var errorType: String {
        return String(describing: self)
    }
}
