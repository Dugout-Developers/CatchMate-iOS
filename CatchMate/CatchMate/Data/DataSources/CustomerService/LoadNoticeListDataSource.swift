//
//  LoadNoticeListDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 2/26/25.
//
import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol LoadNoticeListDataSource {
    func loadNotices(_ page: Int) -> Observable<NoticesListDTO>
}

final class LoadNoticeListDataSourceImpl: LoadNoticeListDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadNotices(_ page: Int) -> Observable<NoticesListDTO> {
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
        
        return APIService.shared.performRequest(type: .noticesList, parameters: parameters, headers: headers, encoding: URLEncoding.default, dataType: NoticesListDTO.self, refreshToken: refreshToken)
            .map { dto in
                LoggerService.shared.log("공지사항 조회 성공: \(dto)")
                return dto
            }
            .catch { error in
                LoggerService.shared.log("공지사항 조회 실패: \(error)")
                return Observable.error(error)
            }
    }
}
