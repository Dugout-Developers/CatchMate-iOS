//
//  ProfileEditDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 12/13/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol ProfileEditDataSource {
    func editProfile(editModel: ProfileEditRequestDTO) -> Observable<ProfileEditResponseDTO>
}

final class ProfileEditDataSourceImpl: ProfileEditDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }
    
//    func editProfile(editModel: ProfileEditRequestDTO) -> Observable<ProfileEditResponseDTO> {
//        guard let token = tokenDataSource.getToken(for: .accessToken) else {
//            return Observable.error(TokenError.notFoundAccessToken)
//        }
//        print(editModel)
//        let headers: HTTPHeaders = [
//            "AccessToken": token
//        ]
//        let parameters = APIService.shared.convertToDictionary(editModel)
//
//        return APIService.shared.requestAPI(type: .editProfile, parameters: parameters, headers: headers, encoding: JSONEncoding.default, dataType: ProfileEditResponseDTO.self)
//            .map { dto in
//                LoggerService.shared.debugLog("Profile Edit 성공: \(dto)")
//                return dto
//            }
//            .catch { [weak self] error in
//                guard let self else {
//                    return Observable.error(OtherError.notFoundSelf)
//                }
//                if let error = error as? NetworkError, error.statusCode == 401 {
//                    guard let refeshToken = tokenDataSource.getToken(for: .refreshToken) else {
//                        return Observable.error(TokenError.notFoundRefreshToken)
//                    }
//                    return APIService.shared.refreshAccessToken(refreshToken: refeshToken)
//                        .flatMap { token -> Observable<ProfileEditResponseDTO> in
//                            let newHeaders: HTTPHeaders = [
//                                "AccessToken": token
//                            ]
//                            LoggerService.shared.debugLog("토큰 재발급 후 재시도 \(token)")
//                            return APIService.shared.requestAPI(type: .editProfile, parameters: parameters, headers: newHeaders, encoding: JSONEncoding.default, dataType: ProfileEditResponseDTO.self)
//                                .map { dto in
//                                    LoggerService.shared.debugLog("Profile Edit 성공: \(dto)")
//                                    return dto
//                                }
//                        }
//                        .catch { error in
//                            return Observable.error(error)
//                        }
//                }
//                return Observable.error(error)
//            }
//    }
    func editProfile(editModel: ProfileEditRequestDTO) -> Observable<ProfileEditResponseDTO> {
        guard let base = Bundle.main.baseURL else {
            LoggerService.shared.log("base 찾기 실패", level: .error)
            return Observable.error(NetworkError.notFoundBaseURL)
        }
        let url = base + Endpoint.editProfile.endPoint
        
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
    
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]

        return Observable.create { observer in
            AF.upload(multipartFormData: { multipartFormData in
                // 1. JSON 데이터 추가
                if let requestJSONData = try? JSONEncoder().encode(editModel.request) {
                    multipartFormData.append(requestJSONData, withName: "request", mimeType: "application/json")
                }

                // 2. 프로필 이미지 추가
                if let resizeImage = ProfileImageHelper.resizeImage(editModel.profileImage, to: CGSize(width: 200, height: 200)), let jpegData = resizeImage.jpegData(compressionQuality: 0.2) {
                    print("image: \(jpegData)")
                    multipartFormData.append(jpegData, withName: "profileImage", fileName: "profile.jpg", mimeType: "image/jpeg")
                } else {
                    print("Invalid Base64 profileImage string or failed to convert to JPEG data")
                }
            }, to: url, method: .patch, headers: headers)
            .responseDecodable(of: ProfileEditResponseDTO.self) { response in
                print("statusCode: \(response.response?.statusCode)")
                print(response.response)
                switch response.result {
                case .success(let responseDTO):
                    print("하")
                    observer.onNext(responseDTO) // 성공 시 데이터 반환
                    observer.onCompleted()
                case .failure(let error):
                    print("\(error)")
                    observer.onError(error) // 실패 시 에러 반환
                }
            }

            return Disposables.create()
        }
    }
}
