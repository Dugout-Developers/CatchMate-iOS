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
    let chatMessageId: String
    
    static let timeFormat = "yyyy-MM-dd'T'HH:mm:ss"
    init(messageType: ChatMessageType, senderId: Int, content: String, chatMessageId: String) {
        self.messageType = messageType.serverRequest
        self.senderId = senderId
        self.content = content
        self.sendTime = ChatSocketMessage.currentISO8601Time()
        self.chatMessageId = chatMessageId
    }
    
    init(messageType: ChatMessageType, senderId: Int, content: String, date: String, chatMessageId: String) {
        self.messageType = messageType.serverRequest
        self.senderId = senderId
        self.content = content
        let newDate = date.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
        self.sendTime = newDate
        self.chatMessageId = chatMessageId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.messageType = try container.decode(String.self, forKey: .messageType)
        self.senderId = try container.decode(Int.self, forKey: .senderId)
        self.content = try container.decode(String.self, forKey: .content)
        self.chatMessageId = try container.decode(String.self, forKey: .chatMessageId)
        
        // ✅ sendTime이 없으면 현재 시간으로 대체
        self.sendTime = (try? container.decode(String.self, forKey: .sendTime)) ?? ChatSocketMessage.currentISO8601Time()
    }
    
    
    static func currentISO8601Time() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = self.timeFormat
        formatter.timeZone = TimeZone(identifier: "UTC")
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
    let isSocket: Bool
    let id: String
}

extension ChatMessage: Equatable {
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.message == rhs.message && lhs.time == rhs.time
    }
    
    func isEqualTime(_ otherMessage: ChatMessage) -> Bool {
        let calendar = Calendar.current
        let selfComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self.time)
        let otherComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: otherMessage.time)
        
        return selfComponents == otherComponents
    }
}

struct ChatListSocket: Codable {
    let chatRoomId: Int
    let content: String
    let sendTime: String
    
    static func decode(from jsonString: String) -> ChatListSocket? {
        let cleanedString = jsonString.trimmingCharacters(in: .controlCharacters)
        
        guard let jsonData = cleanedString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ChatListSocket.self, from: jsonData)
    }
}
