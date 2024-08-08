//
//  KeychainService.swift
//  CatchMate
//
//  Created by 방유빈 on 7/30/24.
//

import Security
import Foundation

enum TokenError: LocalizedError {
    case notFoundAccessToken
    case notFoundRefreshToken
    var statusCode: Int {
        switch self {
        case .notFoundAccessToken:
            return -1001
        case .notFoundRefreshToken:
            return -1002
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .notFoundAccessToken:
            return "엑세스 토큰 찾기 실패"
        case .notFoundRefreshToken:
            return "리프레시 토큰 찾기 실패"
        }
    }
}

final class KeychainService {
    // 키체인에 데이터 저장
    @discardableResult
    static func saveToken(token: String, for type: TokenType) -> Bool {
        let data = token.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: type.rawValue,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: type.rawValue
            ]
            let updateAttributes: [String: Any] = [
                kSecValueData as String: data
            ]
            SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
        }
        
        return status == errSecSuccess || status == errSecDuplicateItem
    }
    
    // 키체인에서 데이터 읽기
    static func getToken(for type: TokenType) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: type.rawValue,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                return String(data: retrievedData, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    // 키체인에서 데이터 삭제
    static func deleteToken(for type: TokenType) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: type.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess
    }
    
    // 토큰 타입 정의
    enum TokenType: String {
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
    }
}
