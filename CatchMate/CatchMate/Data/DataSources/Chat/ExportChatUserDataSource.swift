//
//  ExportChatUserDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 2/14/25.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol ExportChatUserDataSource {
    func exportUser(roomId: Int, userId: Int) -> Observable<Bool>
}

final class ExportChatUserDataSourceImpl: ExportChatUserDataSource {
    private let tokenDataSource: TokenDataSource
   
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
    func exportUser(roomId: Int, userId: Int) -> Observable<Bool> {
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
        let addEndPoint = "\(roomId)/users/\(userId)"
        
        return APIService.shared.performRequest(addEndPoint: addEndPoint, type: .exportChatUser, parameters: nil, headers: headers, encoding: URLEncoding.default, dataType: StateResponseDTO.self, refreshToken: refreshToken)
            .map { state in
                return state.state
            }
            .catch { error in
                LoggerService.shared.log("\(userId)번 유저 내보내기 실패 - \(error)")
                return Observable.error(error)
            }
    }
}

