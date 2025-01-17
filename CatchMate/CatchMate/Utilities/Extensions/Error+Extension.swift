//
//  Error+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 8/1/24.
//
import Foundation

protocol LocalizedErrorWithCode: LocalizedError {
    var statusCode: Int { get }
}
extension Error {
    static var errorType: String {
        return String(describing: self)
    }
    
    var statusCode: Int {
        if let errorWithCode = self as? LocalizedErrorWithCode {
            return errorWithCode.statusCode
        }
        return -9999 // 기본값
    }
    
    var errorDescription: String? {
        return (self as? LocalizedError)?.errorDescription ?? "An unexpected error occurred.: \(self.localizedDescription)"
    }
}
