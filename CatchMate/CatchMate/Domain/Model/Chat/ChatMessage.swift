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
    case leaveUser
    case startChat
    
    init?(serverRequest: String) {
        switch serverRequest {
        case "TALK":
            self = .talk
        case "START":
            self = .startChat
        case "ENTER":
            self = .enterUser
        case "LEAVE":
            self = .leaveUser
        case "DATE":
            self = .date
        default:
            return nil
        }
    }
    var serverRequest: String {
        switch self {
        case .talk:
            return "TALK"
        case .date:
            return "DATE"
        case .enterUser:
            return "ENTER"
        case .leaveUser:
            return "LEAVE"
        case .startChat:
            return "START"
        }
    }
}

struct SendMessage: Codable {
    let messageType: String
    let senderId: Int
    let content: String
    
    init(messageType: ChatMessageType, senderId: Int, content: String) {
        self.messageType = messageType.serverRequest
        self.senderId = senderId
        self.content = content
    }
}
extension SendMessage {
    func encodeMessage() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
        return String(data: jsonData, encoding: .utf8)
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
        self.sendTime = ChatSocketMessage.currentISO8601Time()
    }
    
    init(messageType: ChatMessageType, senderId: Int, content: String, date: String) {
        self.messageType = messageType.serverRequest
        self.senderId = senderId
        self.content = content
        let newDate = date.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
        self.sendTime = newDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.messageType = try container.decode(String.self, forKey: .messageType)
        self.senderId = try container.decode(Int.self, forKey: .senderId)
        self.content = try container.decode(String.self, forKey: .content)
        
        // ✅ sendTime이 없으면 현재 시간으로 대체
        self.sendTime = (try? container.decode(String.self, forKey: .sendTime)) ?? ChatSocketMessage.currentISO8601Time()
    }
    
    
    static func currentISO8601Time() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone.current // 로컬 시간
        return formatter.string(from: Date())
    }
}

extension ChatSocketMessage {
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
