//
//  ChatMessage.swift
//  CatchMate
//
//  Created by 방유빈 on 1/31/25.
//

import Foundation

enum ChatMessageType {
    case talk
    case date
    case enterUser
    case startChat
    
    init?(serverRequest: String) {
        switch serverRequest {
        case "TALK":
            self = .talk
        default:
            return nil
        }
    }
    var serverRequest: String {
        switch self {
        case .talk:
            return "TALK"
        case .date:
            return ""
        case .enterUser:
            return ""
        case .startChat:
            return ""
        }
    }
}

struct ChatSocketMessage: Codable {
    let messageType: String
    let senderId: Int
    let content: String
    let sendTime: String // "2025-01-31T15:20:00" - ISO8601 포맷
    
    init(messageType: ChatMessageType, senderId: Int, content: String) {
        self.messageType = messageType.serverRequest
        self.senderId = senderId
        self.content = content
        // ✅ Z(UTC) 제거한 ISO8601 시간 포맷 적용
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // Z 제거
        formatter.timeZone = TimeZone.current // 현재 로컬 시간 적용
        self.sendTime = formatter.string(from: Date())
    }
    
    init(messageType: ChatMessageType, senderId: Int, content: String, date: String) {
        self.messageType = messageType.serverRequest
        self.senderId = senderId
        self.content = content
        let newDate = date.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
        self.sendTime = newDate
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

struct ChatMessage {
    let userId: Int
    let nickName: String
    let imageUrl: String?
    let message: String
    let time: Date
    let messageType: ChatMessageType
}
