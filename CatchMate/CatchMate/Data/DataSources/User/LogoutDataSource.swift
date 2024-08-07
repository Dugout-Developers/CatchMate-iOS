//
//  LogoutDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 8/2/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire
enum LogoutError: LocalizedError {
    case notFoundURL
    case decodingError
    case serverError(Int, String)
    var statusCode: Int {
        switch self {
        case .notFoundURL:
            return -1001
        case .decodingError:
            return -1002
        case .serverError(let code, _):
            return code
        }
    }
}
protocol LogoutDataSource {
    func logout(token: String) -> Observable<Bool>
}
struct deleteTokeDTO: Codable {
    let state: Bool
}
final class LogoutDataSourceImpl: LogoutDataSource {
    func logout(token: String) -> RxSwift.Observable<Bool> {
        LoggerService.shared.debugLog("--------------Logout--------------")
        guard let base = Bundle.main.baseURL else {
            LoggerService.shared.log("로그아웃 - BaseUrl 찾기 실패", level: .error)
            return Observable.error(LogoutError.notFoundURL)
        }
        let url = base + "/auth/logout"
        let headers: HTTPHeaders = [
            "RefreshToken": token
        ]
        return RxAlamofire.requestJSON(.delete, url, encoding: JSONEncoding.default, headers: headers)
            .flatMap { (response, data) -> Observable<Bool> in
                if response.statusCode == 200 {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let refreshResponse = try JSONDecoder().decode(deleteTokeDTO.self, from: jsonData)
                        LoggerService.shared.debugLog("\(refreshResponse)")
                        return Observable.just(refreshResponse.state)
                    } catch {
                        LoggerService.shared.log("로그아웃 - 로그아웃 토큰 데이터 디코딩 오류", level: .error)
                        return Observable.error(LogoutError.decodingError)
                    }
                } else {
                    LoggerService.shared.log("로그아웃 실패: \(response.statusCode): \(response.debugDescription)", level: .error)
                    return Observable.error(LogoutError.serverError(response.statusCode, "로그아웃 실패 - 서버에러"))
                }
            }
    }
}
