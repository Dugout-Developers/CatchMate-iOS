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
    static var shared: SocketService?
    
    private let tokenDS = TokenDataSourceImpl()
    private let refreshToken: String
    private var accessToken: String
    private let serverURL: URL
    private var socket: WebSocket?
    private let disposeBag = DisposeBag()
    
    private var subscriptions: [String: String] = [:]
    
    private let messageSubject = PublishSubject<(String, String)>() // (roomID, message)
    private let errorSubject = PublishSubject<Error>()
    private let connectionStatusSubject = BehaviorSubject<Bool>(value: false)
    
    var messageObservable: Observable<(String, String)> {
        return messageSubject.asObservable()
    }
    
    var errorObservable: Observable<Error> {
        return errorSubject.asObservable()
    }
    
    var connectionStatus: Observable<Bool> {
        return connectionStatusSubject.asObservable()
    }
    
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
        
        refreshAccessToken { [weak self] newToken in
            guard let self = self, let validToken = newToken else {
                print("🚨 [ERROR] Access Token을 가져오지 못함. WebSocket 연결 중단")
                self?.errorSubject.onNext(SocketError.notFoundToken) // 🔹 Observable로 에러 전달
                return
            }
            
            self.accessToken = validToken
            self.setupWebSocket() // 🔹 최신 Access Token으로 WebSocket 설정
            self.connect() // 🔹 WebSocket 연결 실행
        }
        
        messageObservable
            .subscribe(onNext: { (roomId, message) in
                print("📩 [DEBUG] Reactor에서 수신한 메시지: \(message)")
            }, onError: { error in
                print("❌ [DEBUG] WebSocket 수신 중 오류 발생: \(error)")
            }, onCompleted: {
                print("✅ [DEBUG] WebSocket 스트림 완료됨")
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        print("💥 [DEBUG] SocketService deinit 호출됨")
    }
    
    private func setupWebSocket() {
        var request = URLRequest(url: serverURL)
        request.timeoutInterval = 5
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization") // 🔹 최신 Access Token 추가

        self.socket = WebSocket(request: request)
        self.socket?.delegate = self
    }
    
    private func refreshAccessToken(completion: @escaping (String?) -> Void) {
        guard let base = Bundle.main.baseURL else {
            LoggerService.shared.log(level: .debug, "Base URL 찾을 수 없음")
            completion(nil)
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
                    completion(newAccessToken)

                case .failure(let error):
                    print("🚨 [ERROR] Access Token 재발급 실패: \(error.localizedDescription)")
                    completion(nil)
                }
            }
    }
    func connect() {
        print("🔄 WebSocket 연결 시도")

        socket?.connect()
    }
    
    func disconnect() {
        socket?.disconnect()
        connectionStatusSubject.onNext(false)
        print("🔴 WebSocket 연결 종료")
    }
    
    // MARK: - STOMP Protocol Methods
    func listSubscribe() {
        do {
            let isConnected = try connectionStatusSubject.value()
            guard isConnected else {
                print("🔄 WebSocket이 연결되지 않음. 연결 후 구독 요청")
                connect()
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    do {
                        let reconnected = try self.connectionStatusSubject.value()
                        if !reconnected {
                            print("❌ 재연결 실패. 에러 방출")
                            self.errorSubject.onNext(SocketError.notConnected)
                        } else {
                            print("✅ 재연결 성공. 구독 진행")
                            self.listSubscribe()
                        }
                    } catch {
                        self.errorSubject.onNext(error)
                    }
                }
                return
            }
            
            let subscriptionID = UUID().uuidString
            subscriptions["0"] = subscriptionID
            
            let frame = """
                SUBSCRIBE
                id:\(subscriptionID)
                destination:/topic/chatList
                
                \0
                """
            socket?.write(string: frame)
            print("✅ 채팅방 리스트 구독 요청 보냄")
            
        } catch {
            print("⚠️ WebSocket 상태 확인 실패: \(error)")
        }
    }
    
    func listUnsubscribe() {
        do {
            let isConnected = try connectionStatusSubject.value()
            guard isConnected else {
                print("⚠️ WebSocket이 연결되지 않음. 구독 해제 불가")
                errorSubject.onNext(SocketError.notConnected)
                return
            }

            guard let subscriptionID = subscriptions["0"] else {
                print("⚠️ 리스트 구독 정보가 없음.")
                return
            }
            
            let frame = """
            UNSUBSCRIBE
            id:\(subscriptionID)

            \0
            """
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.socket?.write(string: frame)
                self.subscriptions.removeValue(forKey: "0")
                print("🚫 채팅방 리스트 구독 해제 요청 전송")
            }

        } catch {
            print("⚠️ WebSocket 상태 확인 실패: \(error)")
            errorSubject.onNext(error)
        }
    }
    func subscribe(roomID: String) {
        do {
            let isConnected = try connectionStatusSubject.value()
            guard isConnected else {
                print("🔄 WebSocket이 연결되지 않음. 연결 후 구독 요청")
                connect()
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    do {
                        let reconnected = try self.connectionStatusSubject.value()
                        if !reconnected {
                            print("❌ 재연결 실패. 에러 방출")
                            self.errorSubject.onNext(SocketError.notConnected)
                        } else {
                            print("✅ 재연결 성공. 구독 진행")
                            self.subscribe(roomID: roomID)
                        }
                    } catch {
                        self.errorSubject.onNext(error)
                    }
                }
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
            socket?.write(string: frame)
            print("✅ 채팅방 \(roomID) 구독 요청 보냄")
            UserDefaults.standard.set(roomID, forKey: UserDefaultsKeys.ChatInfo.chatRoomId)
            
        } catch {
            print("⚠️ WebSocket 상태 확인 실패: \(error)")
        }
    }
    
    func unsubscribe(roomID: String) {
        do {
            let isConnected = try connectionStatusSubject.value()
            guard isConnected else {
                print("⚠️ WebSocket이 연결되지 않음. 구독 해제 불가")
                errorSubject.onNext(SocketError.notConnected)
                return
            }

            guard let subscriptionID = subscriptions[roomID] else {
                print("⚠️ 채팅방 \(roomID) 구독 정보가 없음.")
                return
            }

            readMessage(roomId: roomID)
            
            let frame = """
            UNSUBSCRIBE
            id:\(subscriptionID)

            \0
            """
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.socket?.write(string: frame)
                self.subscriptions.removeValue(forKey: roomID)
                print("🚫 채팅방 \(roomID) 구독 해제 요청 전송")
                UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.ChatInfo.chatRoomId)
            }

        } catch {
            print("⚠️ WebSocket 상태 확인 실패: \(error)")
            errorSubject.onNext(error)
        }
    }
    
    func readMessage(roomId: String) {
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
        do {
            let isConnected = try connectionStatusSubject.value()
            guard isConnected else {
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

        } catch {
            print("⚠️ WebSocket 상태 확인 실패: \(error)")
        }
    }
    
    // 기존 구독 복원 (재연결 시 실행)
    private func restoreSubscriptions() {
        for (roomID, _) in subscriptions {
            subscribe(roomID: roomID)
        }
    }
}

// MARK: - WebSocket 이벤트 처리
extension SocketService: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        print("⚡️ WebSocket 이벤트 수신: \(event)")
        switch event {
        case .connected:
            connectionStatusSubject.onNext(true)
            print("✅ WebSocket 연결 성공")
            restoreSubscriptions()
            sendConnectFrame()
            
        case .disconnected(let reason, let code):
            connectionStatusSubject.onNext(false)
            print("🔴 WebSocket 연결 해제됨: \(reason) (code: \(code))")
            
            connectionStatusSubject.onNext(false)
            print("🔴 WebSocket 연결 해제됨: \(reason) (code: \(code))")
            
            // ✅ 403 Forbidden 발생 시, Access Token 갱신 후 WebSocket 재연결
            if code == 403 {
                print("🔄 [DEBUG] Access Token 재발급 후 WebSocket 재연결 중...")
                refreshAccessToken { [weak self] newToken in
                    guard let self = self, let validToken = newToken else {
                        print("🚨 [ERROR] Access Token 재발급 실패. WebSocket 재연결 불가")
                        return
                    }
                    self.accessToken = validToken
                    self.setupWebSocket() // 🔹 최신 Access Token으로 WebSocket 설정
                    self.retryConnection()
                }
            } else {
                // ✅ 403 이외의 다른 오류는 일정 시간 후 재연결
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.connect()
                }
            }
            
        case .text(let text):
            handleIncomingMessage(text)
            
        case .error(let error):
            connectionStatusSubject.onNext(false)
            if let error = error {
                print("🚨 [ERROR] WebSocket 내부 오류 발생: \(error.localizedDescription)")
                errorSubject.onNext(error)
            }
            retryConnection()
            
        default:
            break
        }
    }
    
    private func retryConnection() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.connect()
        }
    }
    
    private func sendConnectFrame() {
        let frame = """
           CONNECT
           accept-version:1.2
           host:\(serverURL.host ?? "localhost")
           
           \0
           """
        socket?.write(string: frame)
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
