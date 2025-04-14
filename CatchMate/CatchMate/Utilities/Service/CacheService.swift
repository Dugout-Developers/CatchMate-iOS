//
//  CacheService.swift
//  CatchMate
//
//  Created by 방유빈 on 4/10/25.
//

import Foundation

enum CacheType {
    case postList
    
    var fileName: String {
        switch self {
        case .postList:
            return "PostListCache.json"
        }
    }
    
    var maxAge: TimeInterval {
        switch self {
        case .postList:
            return 60 * 15 // 15분
        }
    }
}
final class CacheService {
    enum CacheError: Error {
        case cacheDirectoryNotFound
    }
    
    static let shared = try? CacheService()
    private let cacheDirectory: URL

    init() throws {
        guard let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw CacheError.cacheDirectoryNotFound
        }
        self.cacheDirectory = directory
    }
    /// 저장
    func save<T: Codable>(_ object: T, to type: CacheType) {
        let fileURL = cacheDirectory.appendingPathComponent(type.fileName)
        do {
            let data = try JSONEncoder().encode(object)
            try data.write(to: fileURL)
        } catch {
            print("❌ 캐시 저장 실패: \(error)")
        }
    }

    /// 로드
    func load<T: Codable>(from type: CacheType) -> T? {
        let fileURL = cacheDirectory.appendingPathComponent(type.fileName)
        do {
            let data = try Data(contentsOf: fileURL)
            let object = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            print("❌ 캐시 로드 실패: \(error)")
            return nil
        }
    }

    /// 캐시 유효성 검사 (초 단위로 만료 시간 지정)
    func isCacheValid(for type: CacheType) -> Bool {
        let fileURL = cacheDirectory.appendingPathComponent(type.fileName)
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
              let modificationDate = attributes[.modificationDate] as? Date else {
            return false
        }
        let age = Date().timeIntervalSince(modificationDate)
        return age < type.maxAge
    }

    /// 삭제
    func clear(type: CacheType) {
        let fileURL = cacheDirectory.appendingPathComponent(type.fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }
}
