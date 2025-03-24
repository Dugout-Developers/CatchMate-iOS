//
//  KeychainService.swift
//  CatchMate
//
//  Created by 방유빈 on 7/30/24.
//

import Security
import Foundation

// 토큰 타입 정의
enum TokenType: String {
    case accessToken = "accessToken"
    case refreshToken = "refreshToken"
}

protocol TokenDataSource {
    func saveToken(token: String, for type: TokenType) -> Bool
    func getToken(for type: TokenType) -> String?
    func deleteToken(for type: TokenType) -> Bool
}

final class TokenDataSourceImpl: TokenDataSource {
    // 키체인에 데이터 저장
    @discardableResult
    func saveToken(token: String, for type: TokenType) -> Bool {
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
    func getToken(for type: TokenType) -> String? {
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
    func deleteToken(for type: TokenType) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: type.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess
    }
    
    func deleteTokenAll() -> Bool {
        let accessResult = deleteToken(for: .accessToken)
        let refreshResult = deleteToken(for: .refreshToken)
        
        LoggerService.shared.log(level: .debug, "AccessToken 삭제 결과 : \(accessResult), RefreshToken 삭제 결과 : \(refreshResult)")
        
        return accessResult && refreshResult
    }
}
