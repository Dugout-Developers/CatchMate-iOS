//
//  NicknameCheckDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 7/30/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol NicknameCheckDataSource {
    func checkNickname(_ nickname: String) -> Observable<Bool>
}

final class NicknameCheckDataSourceImpl: NicknameCheckDataSource {
    func checkNickname(_ nickname: String) -> RxSwift.Observable<Bool> {
        guard let base = Bundle.main.baseURL else {
            return Observable.error(NetworkError.notFoundBaseURL)
        }
        let url = base + "/auth/check-nickname"
        let urlString = url + "?" + "nickName=\(nickname)"

        return RxAlamofire.requestJSON(.get, urlString)
            .flatMap { (response, json) -> Observable<Bool> in
                guard 200...300 ~= response.statusCode else {
                    LoggerService.shared.log(level: .debug, "닉네임 검사 실패(\(response.statusCode) - \(response.description)")
                    return Observable.error(NetworkError(serverStatusCode: response.statusCode))
                }
                
                if let jsonDict = json as? [String: Any], let result = jsonDict["available"] as? Bool {
                    return Observable.just(result)
                } else {
                    LoggerService.shared.log(level: .debug, "닉네임 체크 응답값 찾을 수 없음")
                    return Observable.error(CodableError.emptyValue("nicknameCheck - available"))
                }
            }
    }
}



