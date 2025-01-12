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
            return Observable.error(TokenError.notFoundAccessToken)
        }
        
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        let addEndPoint = "\(postId)/lift-up"
        
        return APIService.shared.performRequest(addEndPoint: addEndPoint, type: .upPost, parameters: nil, headers: headers, encoding: JSONEncoding.default, dataType: UpPostResponseDTO.self, refreshToken: refreshToken)
            .map { dto in
                LoggerService.shared.debugLog("liftUp API 호출 성공: \(dto)")
                return dto
            }
            .catch { error in
                LoggerService.shared.debugLog("liftUp API 호출 실패 - \(error)")
                return Observable.error(error)
            }
    }
}
