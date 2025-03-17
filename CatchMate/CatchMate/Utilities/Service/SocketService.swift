//
//  SocketService.swift
//  CatchMate
//
//  Created by 방유빈 on 1/27/25.
//

import Foundation
import Starscream
import RxSwift
import Alamofire

struct TokenResponse: Codable {
    let accessToken: String
}
enum SocketError: LocalizedErrorWithCode {
    case invalidURL
    case notConnected
    case disconnected(reason: String, code: Int)
    case invalidMessage
    case subscriptionFailed(roomID: String)
    case unsubscriptionFailed(roomID: String)
    case sendFailed(reason: String)
    case notFoundToken
    
    var statusCode: Int {
        switch self {
        case .invalidURL:
            return -10001
        case .notConnected:
            return -10002
        case .disconnected:
            return -10003
        case .invalidMessage:
            return -10004
        case .subscriptionFailed:
            return -10005
        case .unsubscriptionFailed:
            return -10006
        case .sendFailed:
            return -10007
        case .notFoundToken:
            return -10008
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL 형식이 잘못되었습니다."
        case .notConnected:
            return "소켓이 연결되어 있지 않아 요청을 처리할 수 없습니다."
        case .disconnected(let reason, let code):
            return "소켓 연결이 끊어졌습니다. (사유: \(reason), 코드: \(code))"
        case .invalidMessage:
            return "수신한 메시지의 형식이 올바르지 않습니다."
        case .subscriptionFailed(let roomID):
            return "채팅방 \(roomID) 구독에 실패했습니다."
        case .unsubscriptionFailed(let roomID):
            return "채팅방 \(roomID) 구독 해제에 실패했습니다."
        case .sendFailed(let reason):
            return "메시지를 전송할 수 없습니다. (사유: \(reason))"
        case .notFoundToken:
            return "토큰 정보를 찾을 수 없습니다."
        }
    }
}
final class SocketService {
    struct Subscription {
        let roomId: String
        let id: String
    }
    static var shared: SocketService?
    
    private let tokenDS = TokenDataSourceImpl()
    private let refreshToken: String
    private var accessToken: String
    private let serverURL: URL
    private var socket: WebSocket?
    private let disposeBag = DisposeBag()
    
    private var currentSubscription: Subscription? = nil
    private var preRoomId: String? = nil
    private var socketHeaderId: String? = nil
    private var retryCount = 0
    private let messageSubject = PublishSubject<(String, String)>() // (roomID, message)
    private let errorSubject = PublishSubject<Error>()
    private var connectionSatus = false
    
    var messageObservable: Observable<(String, String)> {
        return messageSubject.asObservable()
    }
    
    var errorObservable: Observable<Error> {
        return errorSubject.asObservable()
    }
    
    
    var reconnectTrigger = PublishSubject<String?>()

    init() throws {
        guard let urlString = Bundle.main.socketURL, let url = URL(string: urlString) else {
            throw SocketError.invalidURL
        }
        guard let refreshToken = tokenDS.getToken(for: .refreshToken) else {
            throw SocketError.notFoundToken
        }
        guard let accessToken = tokenDS.getToken(for: .accessToken) else {
            throw SocketError.notFoundToken
        }
        self.serverURL = url
        self.refreshToken = refreshToken
        self.accessToken = accessToken
        self.socket = nil
        
        reconnectTrigger
            .map {
                self.retryCount += 1
                return $0
            }
            .subscribe { roomId in
                Task {
                    if self.retryCount < 2 {
                        await self.connect(chatId: roomId)
                        await self.subscribe(roomID: roomId)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    deinit {
        print("💥 [DEBUG] SocketService deinit 호출됨")
    }
    
    private func setupWebSocket(chatId: String?) {
        var request = URLRequest(url: serverURL)
        request.timeoutInterval = 5
        self.socket = WebSocket(request: request)
        self.socket?.delegate = self
    }
    private func refreshAccessToken() async -> String? {
        return await withCheckedContinuation { continuation in
            guard let base = Bundle.main.baseURL else {
                print("🚨 [ERROR] Base URL 찾을 수 없음")
                continuation.resume(returning: nil)
                return
            }

            let url = base + "/auth/reissue"
            let headers: HTTPHeaders = [
                "RefreshToken": refreshToken
            ]

            AF.request(url, method: .post, headers: headers)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: TokenResponse.self) { response in
                    switch response.result {
                    case .success(let tokenResponse):
                        let newAccessToken = tokenResponse.accessToken
                        self.tokenDS.saveToken(token: newAccessToken, for: .accessToken)
                        print("✅ [DEBUG] Access Token 재발급 성공: \(newAccessToken)")
                        continuation.resume(returning: newAccessToken)

                    case .failure(let error):
                        print("🚨 [ERROR] Access Token 재발급 실패: \(error.localizedDescription)")
                        continuation.resume(returning: nil)
                    }
                }
        }
    }
    func connect(chatId: String?) async {
        print("🔄 WebSocket 연결 시도")
        self.preRoomId = chatId
        self.setupWebSocket(chatId: chatId)
        socketHeaderId = chatId
        socket?.connect()
        self.connectionSatus = true
        if let id = chatId {
            UserDefaults.standard.set(id, forKey: UserDefaultsKeys.ChatInfo.chatRoomId)
        }
    }
    private func socketDisconnect(_ isIdRemove: Bool) async {
        if isIdRemove {
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.ChatInfo.chatRoomId)
        }
        socket?.disconnect()
        connectionSatus = false
        print("🔴 WebSocket 연결 종료")
    }
    
    // MARK: - STOMP Protocol Methods
    private func subscribe(roomID: String?) async {
        guard connectionSatus else {
            print("❌ [ERROR] WebSocket 연결 실패. 채팅방 구독 재시도 요청")
            reconnectTrigger.onNext(roomID)
            return
        }
        
        let newSubscription = Subscription(roomId: roomID ?? "0", id: UUID().uuidString)
        currentSubscription = newSubscription
        let destination = roomID == nil ? "/topic/chatList" : "/topic/chat.\(roomID!)"
        
        let frame = """
                SUBSCRIBE
                id:\(newSubscription.id)
                destination:\(destination)
                
                \0
                """
        socket?.write(string: frame)
        print("✅ 구독 요청 보냄")
    }
    
    func disconnect(isIdRemove: Bool = true) {
        guard connectionSatus else {
            print("⚠️ WebSocket이 연결되지 않음. 구독 해제 불가")
            errorSubject.onNext(SocketError.notConnected)
            return
        }
        
        guard let subscription = currentSubscription else {
            print("⚠️ 구독 정보가 없음.")
            return
        }
        retryCount = 0
        socketHeaderId = nil
        Task {
            await readMessage(roomId: subscription.roomId)
            await unsubscribe(id: subscription.id)
            await sendDisConnectFrame()
            await socketDisconnect(isIdRemove)
        }
    }
    
    private func unsubscribe(id: String) async {
        let frame = """
            UNSUBSCRIBE
            id:\(id)
            
            \0
            """
        
        self.socket?.write(string: frame)
        self.currentSubscription = nil
        print("🚫 구독 해제 요청 전송 완료")
    }
    
    func readMessage(roomId: String) async {
        if roomId == "0" {
            return
        }
        print("✅ readMessage")
        guard let userId = SetupInfoService.shared.getUserInfo(type: .id) else { return }
        let messageData: [String: Any] = [
            "chatRoomId": Int(roomId)!,
            "userId": Int(userId)!
        ]
        
        // JSON을 문자열로 변환
        guard let jsonData = try? JSONSerialization.data(withJSONObject: messageData, options: []),
              let message = String(data: jsonData, encoding: .utf8) else {
            print("❌ JSON 직렬화 실패")
            return
        }
        let frame = """
        SEND
        destination:/app/chat/read
        content-type:application/json

        \(message)\0
        """
        socket?.write(string: frame)
        print("📩 채팅방 \(roomId) 읽음 메시지 전송 완료: \(frame)")
    }
    
    func sendMessage(to roomID: String, message: String) {
        guard connectionSatus else {
            print("⚠️ WebSocket이 연결되지 않음. 메시지 전송 불가")
            errorSubject.onNext(SocketError.notConnected)
            
            return
        }
        
        let frame = """
            SEND
            destination:/app/chat.\(roomID)
            content-type:application/json
            
            \(message)\0
            """
        guard let socket else {
            print("Send Socket X")
            return
        }
        socket.write(string: frame, completion: {
            print("✅ [DEBUG] WebSocket write 완료됨")
        })
        print("📤 WebSocket 메시지 전송: \(frame)")
    }
    
    // 기존 구독 복원 (재연결 시 실행)
    private func restoreSubscriptions() async {
        Task {
            await subscribe(roomID: currentSubscription?.roomId)
        }
    }
}

// MARK: - WebSocket 이벤트 처리
extension SocketService: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        print("⚡️ WebSocket 이벤트 수신: \(event)")
        switch event {
        case .connected:
            connectionSatus = true
            print("✅ WebSocket 연결 성공")
            Task {
                await sendConnectFrame()
                await subscribe(roomID: socketHeaderId)
            }
            
        case .disconnected(let reason, let code):
            connectionSatus = false
            print("🔴 WebSocket 연결 해제됨: \(reason) (code: \(code))")
            
            // ✅ 403 Forbidden 발생 시, Access Token 갱신 후 WebSocket 재연결
            if code == 403 {
                print("🔄 [DEBUG] Access Token 재발급 후 WebSocket 재연결 중...")
                Task {
                    if let validToken = await refreshAccessToken() {
                        self.accessToken = validToken
                        self.reconnectTrigger.onNext(preRoomId)
                    }
                }
            } else {
                self.reconnectTrigger.onNext(preRoomId)
            }
            
        case .text(let text):
            handleIncomingMessage(text)
            
        case .error(let error):
            connectionSatus = false
            if let error = error {
                print(error.statusCode)
                print("🚨 [ERROR] WebSocket 내부 오류 발생: \(error.localizedDescription)")
                errorSubject.onNext(error)
            }
            self.reconnectTrigger.onNext(preRoomId)
            
        default:
            break
        }
    }

    private func sendConnectFrame() async {
        
        let frame = socketHeaderId != nil ? """
           CONNECT
           accept-version:1.2
           AccessToken:\(accessToken)
           ChatRoomId:\(socketHeaderId!)
           host:\(serverURL.host ?? "localhost")
           
           \0
           """ : """
           CONNECT
           accept-version:1.2
           host:\(serverURL.host ?? "localhost")
           
           \0
           """
        print(frame)
        socket?.write(string: frame)
    }
    
    private func sendDisConnectFrame() async {
        let frame = """
           DISCONNECT

           \0
           """
        socket?.write(string: frame)
        print("📩 [DEBUG] DISCONNECT Frame 전송")
    }
    
    private func handleIncomingMessage(_ text: String) {
        print("📩 [DEBUG] 수신된 원본 메시지: \(text)")

        let messageType = text.components(separatedBy: "\n").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        print("ℹ️ [DEBUG] messageType: \(messageType)")
        
        switch messageType {
        case "CONNECTED":
            print("📩 CONNECTED 수신")
            return
            
        case "MESSAGE":
            print("📩 MESSAGE 수신")
            if let destination = extractValue(from: text, key: "destination"),
               let messageBody = extractBody(from: text),
               let roomID = destination.split(separator: ".").last.map(String.init) {
                print("✅ [DEBUG] WebSocket 메시지 정상 파싱 완료! roomID: \(roomID), messageBody: \(messageBody)")
                messageSubject.onNext((roomID, messageBody))
            } else {
                print("❌ [DEBUG] 메시지 파싱 실패")
                errorSubject.onNext(SocketError.invalidMessage)
            }
            
        case "ERROR":
            print("📩 ERROR 수신")
            let errorMessage = extractValue(from: text, key: "message") ?? "알 수 없는 오류 발생"
            errorSubject.onNext(SocketError.sendFailed(reason: errorMessage))
            
        case "RECEIPT":
            print("📩 RECEIPT 수신")
            let receiptID = extractValue(from: text, key: "receipt-id") ?? "Unknown"
            print("요청 성공 확인 (Receipt ID: \(receiptID))")
            
        default:
            errorSubject.onNext(SocketError.invalidMessage)
        }
    }
    
    private func extractValue(from text: String, key: String) -> String? {
        return text
            .components(separatedBy: "\n")
            .first(where: { $0.starts(with: key) })?
            .replacingOccurrences(of: "\(key):", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func extractBody(from text: String) -> String? {
        return text.components(separatedBy: "\n\n").last?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
