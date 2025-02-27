//
//  ReportUserDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 2/17/25.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol ReportUserDataSource {
    func reportUser(reportInfo: ReportUserDTO, userId: Int) -> Observable<Bool>
}

final class ReportUserDataSourceImpl: ReportUserDataSource {
    private let tokenDataSource: TokenDataSource

    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func reportUser(reportInfo: ReportUserDTO, userId: Int) -> Observable<Bool> {
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
        guard let parameters = APIService.shared.convertToDictionary(reportInfo) else {
            LoggerService.shared.log(level: .debug, "파라미터 인코딩 실패")
            return Observable.error(CodableError.encodingFailed)
        }
        
        LoggerService.shared.log("인코딩 파라미터: \(parameters)")
        return APIService.shared.performRequest(addEndPoint: "/\(userId)" ,type: .report, parameters: parameters, headers: headers, encoding: JSONEncoding.default, dataType: StateResponseDTO.self, refreshToken: refreshToken)
            .map { dto in
                LoggerService.shared.log(level: .debug, "\(userId)번 유저 신고 \(dto.state)")
                return dto.state
            }
            .catch { error in
                LoggerService.shared.log(level: .debug, "\(userId)번 유저 신고 실패 : \(error)")
                return Observable.error(error)
            }
    }
}
