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
    func upPost(_ postId: Int) -> Observable<Bool>
}

final class UpPostDataSourceImpl: UpPostDataSource {
    private let tokenDataSource: TokenDataSource
    private let disposeBag: DisposeBag = DisposeBag()
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func upPost(_ postId: Int) -> Observable<Bool> {
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        let addEndPoint = "\(postId)/lift-up"
        
        return APIService.shared.requestAPI(addEndPoint: addEndPoint, type: .upPost, parameters: nil, headers: headers, encoding: JSONEncoding.default, dataType: upPostResponseDTO.self)
            .map { dto in
                LoggerService.shared.debugLog("liftUp 성공: \(dto)")
                return true
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.error(OtherError.notFoundSelf) }
                if let error = error as? NetworkError {
                    if error.statusCode == 401 {
                        guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
                            return Observable.error(TokenError.notFoundRefreshToken)
                        }
                        return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
                            .flatMap { token in
                                let newHeaders: HTTPHeaders = [
                                    "AccessToken": token
                                ]
                                LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
                                return APIService.shared.requestAPI(addEndPoint: addEndPoint, type: .upPost, parameters: nil, headers: newHeaders, encoding: JSONEncoding.default, dataType: upPostResponseDTO.self)
                                    .map { dto in
                                        LoggerService.shared.debugLog("liftUp 성공: \(dto)")
                                        return true
                                    }
                            }
                            .catch { error in
                                return Observable.error(error)
                            }
                    } else if error.statusCode == 400 {
                        return Observable.just(false)
                    }
                }
                return Observable.error(error)
            }
    }
}
    
struct upPostResponseDTO: Codable {
    let boardId: Int
    let liftUpDate: String
}
