//
//  ChatMessage.swift
//  CatchMate
//
//  Created by 방유빈 on 1/31/25.
//

import Foundation

enum ChatMessageType {
    case talk
    
    var serverRequest: String {
        switch self {
        case .talk:
            return "TALK"
        }
    }
}
struct ChatSocketMessage: Codable {
    let messageType: String
    let sender: String
    let content: String
    let sendTime: String // "2025-01-31T15:20:00" - ISO8601 포맷
    
    init(messageType: ChatMessageType, sender: String, content: String) {
        self.messageType = messageType.serverRequest
        self.sender = sender
        self.content = content
        // ✅ Z(UTC) 제거한 ISO8601 시간 포맷 적용
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // Z 제거
            formatter.timeZone = TimeZone.current // 현재 로컬 시간 적용
            self.sendTime = formatter.string(from: Date())
    }
}

extension ChatSocketMessage {
    func encodeMessage() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
    
    static func decode(from jsonString: String) -> ChatSocketMessage? {
        let cleanedString = jsonString.trimmingCharacters(in: .controlCharacters)
        
        guard let jsonData = cleanedString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ChatSocketMessage.self, from: jsonData)
    }
}
