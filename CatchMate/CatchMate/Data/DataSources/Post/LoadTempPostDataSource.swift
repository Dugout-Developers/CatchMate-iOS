//
//  LoadTempPostDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 1/10/25.
//
import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol LoadTempPostDataSource {
    func loadTempPost() -> Observable<PostDTO?>
}

final class LoadTempPostDataSourceImpl: LoadTempPostDataSource {
    private let tokenDataSource: TokenDataSource
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func loadTempPost() -> RxSwift.Observable<PostDTO?> {
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
        
        return APIService.shared.performRequest(type: .loadTempPost, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: PostDTO?.self, refreshToken: refreshToken)
            .catch { error in
                if let error = error as? NetworkError, error.statusCode == 404 {
                    LoggerService.shared.log(level: .debug, "임시저장된 게시물 없음")
                    return Observable.just(nil)
                }
                LoggerService.shared.log(level: .debug, "임시 저장 게시물 불러오기 실패")
                return Observable.error(error)
            }
    }
    
    
}
