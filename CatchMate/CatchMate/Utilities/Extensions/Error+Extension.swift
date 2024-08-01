//
//  Error+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 8/1/24.
//
import Foundation

extension Error {
    var statusCode: Int {
        return (self as? LocalizedError)?.statusCode ?? -9999
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
