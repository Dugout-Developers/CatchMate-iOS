//
//  SocketService.swift
//  CatchMate
//
//  Created by 방유빈 on 1/27/25.
//

import Foundation
import Starscream
import RxSwift

enum SocketError: LocalizedErrorWithCode {
    case invalidURL
    case notConnected
    var statusCode: Int {
        switch self {
        case .invalidURL:
            return -10001
        case .notConnected:
            return -10002
        }
    }
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL 형식이 잘못되었습니다."
        case .notConnected:
            return "소켓이 연결되어 있지않아 요청을 처리할 수 없습니다."
        }
    }
}
final class SocketService: WebSocketDelegate {
    static var shared: SocketService?
    
    private var socket: WebSocket!
    private var isConnected = false
    private let serverURL: URL
    private var subscriptions: [String: String] = [:]
    private let delegateQueue = DispatchQueue(label: "socketService.queue")
    
    // Callbacks
    var onMessageReceived: ((String, String) -> Void)? // (RoomID, Message)
    var onConnectionChange: ((Bool) -> Void)? // IsConnected
    
    init() throws {
        guard let urlString = Bundle.main.socketURL, let url = URL(string: urlString) else {
            throw SocketError.invalidURL
        }
        self.serverURL = url
    }
    
    func connect() {
        var request = URLRequest(url: serverURL)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func disconnect() {
        sendFrame("DISCONNECT\n\n\0")
        socket.disconnect()
        isConnected = false
    }
    
    private func sendFrame(_ frame: String) {
        delegateQueue.async {
            self.socket.write(string: frame)
        }
    }
    
    // MARK: - STOMP Protocol Methods
    func subscribe(roomID: String) {
        guard isConnected else {
            LoggerService.shared.debugLog("❌ WebSocket error: 소켓이 연결되어 있지 않습니다.")
            return
        }
        let subscriptionID = UUID().uuidString
        subscriptions[roomID] = subscriptionID
        let frame = """
           SUBSCRIBE
           id:\(subscriptionID)
           destination:/topic/chat.\(roomID)
           
           \0
           """
        sendFrame(frame)
        LoggerService.shared.debugLog("✅ 채팅방 \(roomID) 구독 요청 보냄")
    }
    
    func unsubscribe(roomID: String) {
        guard let subscriptionID = subscriptions[roomID] else {
            print("Room \(roomID) is not subscribed")
            return
        }
        let frame = """
           UNSUBSCRIBE
           id:\(subscriptionID)
           
           \0
           """
        sendFrame(frame)
        subscriptions.removeValue(forKey: roomID)
    }
    
    func sendMessage(to roomID: String, message: String) {
        guard isConnected else {
            print("Socket is not connected")
            return
        }
        let frame = """
           SEND
           destination:/app/chat.\(roomID)
           content-type: application/json
           
           \(message)\0
           """
        sendFrame(frame)
    }
    // MARK: - WebSocketDelegate Methods
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected:
            isConnected = true
            print("✅ WebSocket connected")
            onConnectionChange?(true)
            sendConnectFrame()
        case .disconnected(let reason, let code):
            isConnected = false
            print("⚠️ WebSocket disconnected: \(reason) with code: \(code)")
            onConnectionChange?(false)
            
            // 🔹 자동 재연결 로직 추가 (5초 후 재연결 시도)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if !self.isConnected {
                    print("🔄 WebSocket 재연결 시도...")
                    self.connect()
                }
            }
        case .text(let text):
            print("📩 WebSocket에서 수신한 원본 메시지: \(text)")
            handleIncomingMessage(text)
        case .error(let error):
            print("❌ WebSocket error: \(String(describing: error))")
            onConnectionChange?(false)
        default:
            break
        }
    }
    
    // MARK: - STOMP CONNECT Frame
    private func sendConnectFrame() {
        let frame = """
           CONNECT
           accept-version:1.2
           host:\(serverURL.host ?? "localhost")
           
           \0
           """
        sendFrame(frame)
    }
    
    // MARK: - Incoming Message Handling
    private func handleIncomingMessage(_ text: String) {

        // 🔹 STOMP 프레임의 첫 번째 라인에서 메시지 타입 추출
        let messageType = text.components(separatedBy: "\n").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        print("ℹ️ messageType: \(messageType)")
        // 🔹 STOMP `CONNECTED` 프레임은 무시
        if messageType == "CONNECTED" {
            print("✅ STOMP 연결 완료 (CONNECTED 프레임 수신)")
            return
        }

        // 🔹 STOMP `MESSAGE` 프레임만 처리
        guard messageType == "MESSAGE" || messageType == "SEND",
              let destination = extractHeader(from: text, key: "destination"),
              let messageBody = extractBody(from: text),
              let roomID = destination.split(separator: ".").last.map(String.init) else {
            print("❌ 메시지 형식이 올바르지 않습니다.")
            return
        }

        // 🔹 내가 구독한 채팅방인지 확인
        if subscriptions.keys.contains(roomID) {
            print("✅ 채팅방 \(roomID)에서 메시지 수신: \(messageBody)")
            onMessageReceived?(roomID, messageBody)
        } else {
            print("🚫 구독하지 않은 채팅방(\(roomID))의 메시지를 무시합니다.")
        }
    }
    
    private func extractHeader(from frame: String, key: String) -> String? {
        let lines = frame.split(separator: "\n")
        for line in lines {
            if line.starts(with: key) {
                return line.replacingOccurrences(of: "\(key):", with: "")
            }
        }
        return nil
    }
    
    private func extractBody(from frame: String) -> String? {
        guard let blankLineIndex = frame.range(of: "\n\n") else {
            return nil
        }
        let bodyStartIndex = frame.index(blankLineIndex.upperBound, offsetBy: 0)
        return String(frame[bodyStartIndex...]).trimmingCharacters(in: .newlines)
    }
}
