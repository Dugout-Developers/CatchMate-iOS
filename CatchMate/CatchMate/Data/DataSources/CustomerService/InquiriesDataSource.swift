//
//  InquiriesDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 2/18/25.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol InquiriesDataSource {
    func sendInquiry(type: String, content: String) -> Observable<Bool>
}

final class InquiriesDataSourceImpl: InquiriesDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func sendInquiry(type: String, content: String) -> RxSwift.Observable<Bool> {
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
            "inquiryType": type,
            "content": content
        ]
        
        return APIService.shared.performRequest(type: .inquiries, parameters: parameters, headers: headers, encoding: JSONEncoding.default, dataType: StateResponseDTO.self, refreshToken: refreshToken)
            .map { dto in
                LoggerService.shared.log("문의 제출 성공: \(dto.state)")
                return dto.state
            }
            .catch { error in
                LoggerService.shared.log("문의 하기 실패: \(error)")
                return Observable.error(error)
            }
    }
    
}
