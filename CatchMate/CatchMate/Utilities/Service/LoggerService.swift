//
//  LoggerService.swift
//  CatchMate
//
//  Created by 방유빈 on 8/1/24.
//

import Foundation

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

class LoggerService {
    static let shared = LoggerService()
    private var logFileHandle: FileHandle?
    private let logQueue = DispatchQueue(label: "logger.queue", qos: .background)
    private var logFilePath: String?

    private init() {}

    func configure(logDirectoryPath: String) {
           let fileManager = FileManager.default
           let expandedLogDirectoryPath = (logDirectoryPath as NSString).expandingTildeInPath
           print("Expanded log directory path: \(expandedLogDirectoryPath)") // 경로 출력

           var isDir: ObjCBool = true
           if !fileManager.fileExists(atPath: expandedLogDirectoryPath, isDirectory: &isDir) {
               do {
                   try fileManager.createDirectory(atPath: expandedLogDirectoryPath, withIntermediateDirectories: true, attributes: nil)
                   print("Log directory created at: \(expandedLogDirectoryPath)") // 성공 메시지
               } catch {
                   print("Failed to create log directory: \(error.localizedDescription)")
                   return
               }
           } else {
               print("Log directory already exists at: \(expandedLogDirectoryPath)") // 디렉토리 존재 메시지
           }
           
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
           let dateString = dateFormatter.string(from: Date())
           let logFileName = "debug_\(dateString).log"
           let logFilePath = (expandedLogDirectoryPath as NSString).appendingPathComponent(logFileName)
           let logFileURL = URL(fileURLWithPath: logFilePath)
           
           if !fileManager.fileExists(atPath: logFileURL.path) {
   
                   fileManager.createFile(atPath: logFileURL.path, contents: nil, attributes: nil)
                   print("Log file created at: \(logFilePath)") // 파일 생성 메시지
     
           } else {
               print("Log file already exists at: \(logFilePath)") // 파일 존재 메시지
           }
           logFileHandle = try? FileHandle(forWritingTo: logFileURL)
       }

    func log(_ message: String, level: LogLevel = .debug) {
        #if DEBUG
        guard let logFileHandle = logFileHandle else { return }
        
        logQueue.async {
            // 메시지에 타임스탬프 추가
            let timestamp = Date().description(with: .current)
            let logMessage = "\(timestamp) [\(level.rawValue)]: \(message)\n"
            
            // 로그 파일에 기록
            if let data = logMessage.data(using: .utf8) {
                logFileHandle.seekToEndOfFile()
                logFileHandle.write(data)
            }
        }
        #endif
    }

    func debugLog(_ message: String) {
        #if DEBUG
        log(message)
        #endif
        print(message)
    }

    deinit {
        logFileHandle?.closeFile()
    }
}
