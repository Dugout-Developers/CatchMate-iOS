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
    func cancelApplyPost(enrollId: String) -> Observable<Void>
}

final class ApplyDataSourceImpl: ApplyDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func applyPost(boardID: String, addInfo: String) -> RxSwift.Observable<Int> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            LoggerService.shared.log(level: .debug, "엑세스 토큰 찾기 실패")
            return Observable.error(TokenError.notFoundAccessToken)
        }
        guard let refreshToken = self.tokenDataSource.getToken(for: .refreshToken) else {
            LoggerService.shared.log(level: .debug, "리프레시 토큰 찾기 실패")
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        let parameters: [String: Any] = ["description": addInfo]

        return APIService.shared.performRequest(addEndPoint: boardID, type: .apply, parameters: parameters, headers: headers, encoding: JSONEncoding.default, dataType: ApplyPostResponse.self, refreshToken: refreshToken)
            .map { response in
                return response.enrollId
            }
            .catch { error in
                LoggerService.shared.log(level: .debug, "직관 신청 실패 - \(error)")
                return Observable.error(error)
            }

    }
    
    func cancelApplyPost(enrollId: String) -> Observable<Void> {
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
        
        return APIService.shared.performRequest(addEndPoint: enrollId, type: .cancelApply, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: CancelApplyPostResponse.self, refreshToken: refeshToken)
            .map { _ -> Void in
                return ()
            }
            .catch { error in
                LoggerService.shared.log(level: .debug, "신청 취소 실패 - \(error)")
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
