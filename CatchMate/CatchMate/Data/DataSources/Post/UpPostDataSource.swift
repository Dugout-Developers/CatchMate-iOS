//
//  UpPostDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 11/13/24.
//
import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol UpPostDataSource {
    func upPost(_ postId: Int) -> Observable<UpPostResponseDTO>
}

final class UpPostDataSourceImpl: UpPostDataSource {
    private let tokenDataSource: TokenDataSource
    private let disposeBag: DisposeBag = DisposeBag()
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func upPost(_ postId: Int) -> Observable<UpPostResponseDTO> {
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
        let addEndPoint = "\(postId)/lift-up"
        
        return APIService.shared.performRequest(addEndPoint: addEndPoint, type: .upPost, parameters: nil, headers: headers, encoding: JSONEncoding.default, dataType: UpPostResponseDTO.self, refreshToken: refreshToken)
            .catch { error in
                LoggerService.shared.log("liftUp API 호출 실패 - \(error)")
                return Observable.error(error)
            }
    }
}
