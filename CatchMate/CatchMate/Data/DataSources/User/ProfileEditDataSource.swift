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

    func editProfile(editModel: ProfileEditRequestDTO) -> Observable<ProfileEditResponseDTO> {
        guard let base = Bundle.main.baseURL else {
            LoggerService.shared.log(level: .debug, "base 찾기 실패")
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
                    LoggerService.shared.log(level: .debug, "이미지 리사이징 실패")
                }
            }, to: url, method: .patch, headers: headers)
            .responseDecodable(of: ProfileEditResponseDTO.self) { response in
                switch response.result {
                case .success(let responseDTO):
                    observer.onNext(responseDTO) // 성공 시 데이터 반환
                    observer.onCompleted()
                case .failure(let error):
                    LoggerService.shared.log(level: .debug, "프로필 수정 요청 실패 - \(error.localizedDescription)")
                    let statusCode = response.response?.statusCode ?? 0
                    observer.onError(NetworkError(serverStatusCode: statusCode))
                }
            }

            return Disposables.create()
        }
    }
}
