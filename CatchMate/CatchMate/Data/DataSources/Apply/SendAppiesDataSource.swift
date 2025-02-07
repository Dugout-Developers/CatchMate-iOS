//
//  MySendApplyDataSoure.swift
//  CatchMate
//
//  Created by 방유빈 on 9/2/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol SendAppiesDataSource {
    func loadSendApplies(page: Int) -> Observable<ApplyListResponse>
}


final class SendAppiesDataSourceImpl: SendAppiesDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    func loadSendApplies(page: Int) -> RxSwift.Observable<ApplyListResponse> {
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

        let parameters: [String: Any] = [
            "page": page
        ]
        return APIService.shared.performRequest(type: .sendApply, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: ApplyListResponse.self, refreshToken: refreshToken)
            .catch { error in
                LoggerService.shared.log(level: .debug, "보낸 신청 목록 load 실패 - \(error)")
                return Observable.error(error)
            }
    }
}
