//
//  ApplyManagementDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 9/3/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol ApplyManagementDataSource {
    func acceptApply(enrollId: String) -> Observable<Bool>
    func rejectApply(enrollId: String) -> Observable<Bool>
}

final class ApplyManagementDataSourceImpl: ApplyManagementDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func acceptApply(enrollId: String) -> RxSwift.Observable<Bool> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        let addEndpoint = "\(enrollId)/accept"
        return APIService.shared.requestAPI(addEndPoint: addEndpoint, type: .acceptApply, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: ApplyManagementResponse.self)
            .flatMap { response -> Observable<Bool> in
                if response.acceptStatus == "ACCEPTED" {
                    return Observable.just(true)
                } else {
                    return Observable.just(false)
                }
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.error(ReferenceError.notFoundSelf) }
                if let error = error as? NetworkError, error.statusCode == 401 {
                    guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
                        return Observable.error(TokenError.notFoundRefreshToken)
                    }
                    return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
                        .flatMap { token -> Observable<Bool> in
                            let newHeaders: HTTPHeaders = [
                                "AccessToken": token
                            ]
                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
                            return APIService.shared.requestAPI(addEndPoint: addEndpoint, type: .acceptApply, parameters: nil, headers: newHeaders, encoding: URLEncoding.default, dataType: ApplyManagementResponse.self)
                                .flatMap { response -> Observable<Bool> in
                                    if response.acceptStatus == "ACCEPTED" {
                                        return Observable.just(true)
                                    } else {
                                        return Observable.just(false)
                                    }
                                }
                        }
                        .catch { error in
                            return Observable.error(error)
                        }
                }
                return Observable.error(error)
            }
    }
    
    func rejectApply(enrollId: String) -> RxSwift.Observable<Bool> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        let addEndpoint = "\(enrollId)/reject"
        return APIService.shared.requestAPI(addEndPoint: addEndpoint, type: .rejectApply, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: ApplyManagementResponse.self)
            .flatMap { response -> Observable<Bool> in
                if response.acceptStatus == "REJECTED" {
                    return Observable.just(true)
                } else {
                    return Observable.just(false)
                }
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.error(ReferenceError.notFoundSelf) }
                if let error = error as? NetworkError, error.statusCode == 401 {
                    guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
                        return Observable.error(TokenError.notFoundRefreshToken)
                    }
                    return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
                        .flatMap { token -> Observable<Bool> in
                            let newHeaders: HTTPHeaders = [
                                "AccessToken": token
                            ]
                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
                            return APIService.shared.requestAPI(addEndPoint: addEndpoint, type: .rejectApply, parameters: nil, headers: newHeaders, encoding: URLEncoding.default, dataType: ApplyManagementResponse.self)
                                .flatMap { response -> Observable<Bool> in
                                    if response.acceptStatus == "REJECTED" {
                                        return Observable.just(true)
                                    } else {
                                        return Observable.just(false)
                                    }
                                }
                        }
                        .catch { error in
                            return Observable.error(error)
                        }
                }
                return Observable.error(error)
            }
    }
    
}

struct ApplyManagementResponse: Codable {
    let enrollId: Int
    let acceptStatus: String
}
