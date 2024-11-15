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
        guard let base = Bundle.main.baseURL else {
            return Observable.error(NetworkError.notFoundBaseURL)
        }
        guard let url = URL(string: (base + Endpoint.upPost.endPoint)) else {
            return Observable.error(OtherError.invalidURL)
        }
        
        return Observable.deferred { [weak self] () -> Observable<Bool> in
                var retryCount = 0 
                return self?.makeRequest(postId: postId, url: url)
                    .catch { error in
                        if let afError = error as? AFError, afError.responseCode == 401, retryCount < 1 {
                            retryCount += 1
                            return self?.refreshToken()
                                .flatMap { _ in
                                    self?.makeRequest(postId: postId, url: url) ?? Observable.error(ReferenceError.notFoundSelf)
                                } ?? Observable.error(ReferenceError.notFoundSelf)
                        }
                        return Observable.error(error)
                    } ?? Observable.error(ReferenceError.notFoundSelf)
            }
    }
    
    private func makeRequest(postId: Int, url: URL) -> Observable<Bool> {
        return Observable<Bool>.create { [weak self] observer in
            guard let self = self else {
                observer.onError(OtherError.invalidURL)
                return Disposables.create()
            }

            guard let token = self.tokenDataSource.getToken(for: .accessToken) else {
                observer.onError(TokenError.notFoundAccessToken)
                return Disposables.create()
            }
            
            let headers: HTTPHeaders = [
                "AccessToken": token
            ]
            LoggerService.shared.log("토큰 확인: \(headers)")

            var request = URLRequest(url: url)
            request.httpMethod = Endpoint.upPost.requstType.rawValue
            request.headers = headers
            request.httpBody = "\(postId)".data(using: .utf8)

            let task = AF.request(request)
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success:
                        observer.onNext(true)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }

            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    private func refreshToken() -> Observable<Void> {
        guard let refreshToken = tokenDataSource.getToken(for: .refreshToken) else {
            return Observable.error(TokenError.notFoundRefreshToken)
        }
        
        // APIService를 사용해 토큰 재발급
        return APIService.shared.refreshAccessToken(refreshToken: refreshToken)
            .flatMap { newAccessToken -> Observable<Void> in
                LoggerService.shared.log("새로운 토큰 발급: \(newAccessToken)")
                // 새로운 토큰 저장
                if self.tokenDataSource.saveToken(token: newAccessToken, for: .accessToken) {
                    return Observable.just(())
                } else {
                    // 실패 시
                    return Observable.error(TokenError.failureSaveToken)
                }
            }

    }
}
