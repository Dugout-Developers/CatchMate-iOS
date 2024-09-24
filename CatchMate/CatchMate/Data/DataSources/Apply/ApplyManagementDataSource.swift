//
//  ApplyManagementDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 9/3/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol ApplyManagementDataSource {
    func acceptApply(enrollId: String) -> Observable<Bool>
    func rejectApply(enrollId: String) -> Observable<Bool>
}

//final class ApplyManagementDataSourceImpl: ApplyManagementDataSource {
//    private let tokenDataSource: TokenDataSource
//    
//    init(tokenDataSource: TokenDataSource) {
//        self.tokenDataSource = tokenDataSource
//    }
//    
//    func acceptApply(enrollId: String) -> RxSwift.Observable<Bool> {
//        guard let token = tokenDataSource.getToken(for: .accessToken) else {
//            return Observable.error(TokenError.notFoundAccessToken)
//        }
//        let headers: HTTPHeaders = [
//            "AccessToken": token
//        ]
//        let parameters: [String: Any] = ["enrollId": enrollId]
//        LoggerService.shared.log("토큰 확인: \(headers)")
//        
//        return APIService.shared.requestAPI(type: .apply, parameters: <#T##[String : Any]?#>, dataType: <#T##(Decodable & Encodable).Type#>)
//    }
//    
//    func rejectApply(enrollId: String) -> RxSwift.Observable<Bool> {
//        <#code#>
//    }
//    
//}
