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
            return Observable.error(TokenError.notFoundAccessToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        return APIService.shared.performRequest(type: .loadTempPost, parameters: nil, headers: headers, dataType: PostDTO.self)
            .map({ dto in
                return dto
            })
            .catch { error in
                if let error = error as? NetworkError, error.statusCode == 404 {
                    LoggerService.shared.debugLog("임시저장된 게시물 없음")
                    return Observable.just(nil)
                }
                return Observable.error(error)
            }
    }
    
    
}
