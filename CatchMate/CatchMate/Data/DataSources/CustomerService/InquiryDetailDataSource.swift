//
//  InquiriyDetailDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 3/20/25.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol InquiryDetailDataSource {
    func loadInquirity(id: Int) -> Observable<InquiryDTO>
}

final class InquiryDetailDataSourceImpl: InquiryDetailDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadInquirity(id: Int) -> Observable<InquiryDTO> {
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

        return APIService.shared.performRequest(addEndPoint: "\(id)", type: .inquiryDetail, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: InquiryDTO.self, refreshToken: refreshToken)
            .map { dto in
                LoggerService.shared.log("문의 답변 디테일 조회 성공: \(dto)")
                return dto
            }
            .catch { error in
                LoggerService.shared.log("문의 답변 디테일실패: \(error)")
                return Observable.error(error)
            }
    }
}

