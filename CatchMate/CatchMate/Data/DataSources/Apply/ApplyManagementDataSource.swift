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
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        let addEndpoint = "\(enrollId)/accept"
        return APIService.shared.performRequest(addEndPoint: addEndpoint, type: .acceptApply, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: ApplyManagementResponse.self, refreshToken: refreshToken)
            .flatMap { response -> Observable<Bool> in
                if response.acceptStatus == "ACCEPTED" {
                    return Observable.just(true)
                } else {
                    return Observable.just(false)
                }
            }
            .catch { error in
                LoggerService.shared.debugLog("직관 신청 수락 실패 - \(error)")
                return Observable.error(error)
            }
    }
    
    func rejectApply(enrollId: String) -> RxSwift.Observable<Bool> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        let addEndpoint = "\(enrollId)/reject"
        return APIService.shared.performRequest(addEndPoint: addEndpoint, type: .rejectApply, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: ApplyManagementResponse.self, refreshToken: refreshToken)
            .flatMap { response -> Observable<Bool> in
                if response.acceptStatus == "REJECTED" {
                    return Observable.just(true)
                } else {
                    return Observable.just(false)
                }
            }
            .catch { error in
                LoggerService.shared.debugLog("직관 신청 거절 실패 - \(error)")
                return Observable.error(error)
            }
    }
    
}

struct ApplyManagementResponse: Codable {
    let enrollId: Int
    let acceptStatus: String
}
