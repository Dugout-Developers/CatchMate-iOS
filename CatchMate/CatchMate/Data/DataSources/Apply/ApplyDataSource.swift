//
//  ApplyDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 9/2/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol ApplyDataSource {
    func applyPost(boardID: String, addInfo: String) -> Observable<Int>
    func cancelApplyPost(enrollId: String) -> Observable<Bool>
}

final class ApplyDataSourceImpl: ApplyDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func applyPost(boardID: String, addInfo: String) -> RxSwift.Observable<Int> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        let parameters: [String: Any] = ["description": addInfo]
        LoggerService.shared.log("토큰 확인: \(headers)")
        
        return APIService.shared.requestAPI(addEndPoint: boardID, type: .apply, parameters: parameters, headers: headers, encoding: JSONEncoding.default, dataType: ApplyPostResponse.self)
            .map { response in
                return response.enrollId
            }
            .catch {[weak self] error in
                guard let self = self else { return Observable.error(ReferenceError.notFoundSelf) }
                if error.statusCode == 401 {
                    guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
                        return Observable.error(TokenError.notFoundRefreshToken)
                    }
                    return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
                        .flatMap { token -> Observable<Int> in
                            let headers: HTTPHeaders = [
                                "AccessToken": token
                            ]
                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
                            return APIService.shared.requestAPI(addEndPoint: boardID, type: .apply, parameters: parameters, headers: headers, encoding: JSONEncoding.default, dataType: ApplyPostResponse.self)
                                .map { response in
                                    LoggerService.shared.debugLog("신청 성공")
                                    return response.enrollId
                                }
                        }
                        .catch { error in
                            LoggerService.shared.debugLog(error.localizedDescription)
                            if error.statusCode == 400 {
                                return Observable.just(-1)
                            }
                            return Observable.error(error)
                        }
                }
                LoggerService.shared.debugLog(error.localizedDescription)
                if error.statusCode == 400 {
                    return Observable.just(-1)
                }
                return Observable.error(error)
            }

    }
    
    func cancelApplyPost(enrollId: String) -> Observable<Bool> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        LoggerService.shared.log("토큰 확인: \(headers)")
        
        return APIService.shared.requestAPI(addEndPoint: enrollId, type: .cancelApply, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: CancelApplyPostResponse.self)
            .map { _ in
                LoggerService.shared.debugLog("신청 취소 성공")
                return true
            }
            .catch { error in
                if error.statusCode == 401 {
                    return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
                        .flatMap { token -> Observable<Bool> in
                            let headers: HTTPHeaders = [
                                "AccessToken": token
                            ]
                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
                            return APIService.shared.requestAPI(addEndPoint: enrollId, type: .cancelApply, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: CancelApplyPostResponse.self)
                                .map { _ in
                                    LoggerService.shared.debugLog("신청 취소 성공")
                                    return true
                                }
                        }
                        .catch { error in
                            LoggerService.shared.debugLog(error.localizedDescription)
                            return Observable.error(error)
                        }
                }
                return Observable.error(error)
            }
    }
}

struct ApplyPostResponse: Codable {
    let enrollId: Int
    let requestAt: String
}

struct CancelApplyPostResponse: Codable {
    let enrollId: Int
    let deletedAt: String
}
