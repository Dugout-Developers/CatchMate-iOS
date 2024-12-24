//
//  MockTokenDataSource.swift
//  CatchMateTests
//
//  Created by 방유빈 on 9/27/24.
//

import XCTest
import RxSwift
import Alamofire
import RxAlamofire

@testable import CatchMate

class MockTokenDataSource: TokenDataSource {
    func saveToken(token: String, for type: TokenType) -> Bool {
        return true
    }
    
    func getToken(for type: TokenType) -> String? {
        switch type {
        case .accessToken:
            return "Bearer eyJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwiZXhwIjoxNzMxNTY5Mzk5fQ.c6nE4fgXTxaD2-9A_Ffi0vH15zV4Mne5nn2tlWFYfGc"
        case .refreshToken:
            return "Bearer eyJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwiZXhwIjoxNzI5MjM1Mzk0fQ.wLxpA92g1sTROHfCxJYpol35VyxOPLTCLGvX_FzkVGE"
        }
    }
    
    func deleteToken(for type: TokenType) -> Bool {
        return true
    }
    
    
}
