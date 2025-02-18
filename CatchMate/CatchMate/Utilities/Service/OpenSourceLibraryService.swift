//
//  OpenSourceLibraryService.swift
//  CatchMate
//
//  Created by 방유빈 on 2/18/25.
//

import Foundation

class OpenSourceLibraryService {
    static let shared = OpenSourceLibraryService()
    
    private init() {}

    func loadLibraries() -> [OpenSourceLibrary] {
        guard let url = Bundle.main.url(forResource: "open_source_licenses", withExtension: "json") else {
            print("❌ JSON 파일을 찾을 수 없음")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([OpenSourceLibrary].self, from: data)
        } catch {
            print("❌ JSON 파싱 실패: \(error.localizedDescription)")
            return []
        }
    }
}
