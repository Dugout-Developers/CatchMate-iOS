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
    func saveUserModel(_ model: SignUpRequest) -> Observable<SignUpResponseDTO>
}


final class SignUpDataSourceImpl: SignUpDataSource {
    func saveUserModel(_ model: SignUpRequest) -> Observable<SignUpResponseDTO> {
        LoggerService.shared.debugLog("-----------------Servser Request SignUp-------------------")
        guard let base = Bundle.main.baseURL else {
            LoggerService.shared.log("SignUp: - BaseURL 찾기 실패", level: .error)
            return Observable.error(NetworkError.notFoundBaseURL)
        }
        
        var parameters: [String: Any] = [
            "email": model.email,
            "provider": model.provider,
            "providerId": model.providerId,
            "gender": model.gender,
            "picture": model.picture ?? "",
            "fcmToken": model.fcmToken,
            "nickName": model.nickName,
            "birthDate": model.birthDate,
            "favGudan": model.favGudan
        ]
        
        if let watchStyle = model.watchStyle {
            parameters["watchStyle"] = watchStyle
        }
        LoggerService.shared.debugLog("SignUp Parameters : \(parameters)")
        return APIService.shared.requestAPI(type: .signUp, parameters: parameters, encoding: JSONEncoding.default, dataType: SignUpResponseDTO.self)
            .map { dto in
                LoggerService.shared.debugLog("회원가입 성공: \(dto)")
                return dto
            }
            .catch { error in
                return Observable.error(error)
            }
       
    }
}



