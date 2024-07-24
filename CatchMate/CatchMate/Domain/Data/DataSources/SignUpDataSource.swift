//
//  SignUpDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 7/23/24.
//

import RxSwift
import RxAlamofire
import Alamofire
import UIKit

protocol SignUpDataSource {
    func saveUserModel(_ model: SignUpModel) -> Observable<Result<SignUpResponseDTO, SignUpAPIError>>
}

enum SignUpAPIError: Error {
    case configError
    case serverError(Int)
    case networkError(Error)
    case decodingError
    case unknownError
}


final class SignUpDataSourceImpl: SignUpDataSource {
    func saveUserModel(_ model: SignUpModel) -> Observable<Result<SignUpResponseDTO, SignUpAPIError>> {
        return Observable<Result<SignUpResponseDTO, SignUpAPIError>>.create { observer in
            // 여기에서 실제 API 호출이나 데이터 저장 작업을 수행합니다.
            guard let base = Bundle.main.baseURL else {
                observer.onNext(.failure(SignUpAPIError.configError))
                observer.onCompleted()
                return Disposables.create()
            }
            let url = base + "/additional-info"
            let parameters: [String: Any] = [
                "nickName": model.nickName,
                "birthDate": model.birth,
                "favoriteGudan": model.team.rawValue,
                "watchStyle": model.cheerStyle as Any,
            ]
            let headers: HTTPHeaders = [
                "AccessToken": model.accessToken
            ]
            RxAlamofire.requestJSON(.patch, url, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .subscribe(onNext: { (response, data) in
                    if response.statusCode == 200 {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                            let signUpResponse = try JSONDecoder().decode(SignUpResponseDTO.self, from: jsonData)
                            observer.onNext(.success(signUpResponse))
                        } catch {
                            observer.onNext(.failure(SignUpAPIError.decodingError))
                        }
                    } else {
                        // 서버 에러
                        observer.onNext(.failure(SignUpAPIError.serverError(response.statusCode)))
                    }
                    observer.onCompleted()
                }, onError: { error in
                    // 네트워크 에러
                    observer.onNext(.failure(SignUpAPIError.networkError(error)))
                    observer.onCompleted()
                })
                .disposed(by: DisposeBag())
            return Disposables.create()
        }
    }
}

