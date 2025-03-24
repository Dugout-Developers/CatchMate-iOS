//
//  UpdateChatImageDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 2/13/25.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol UpdateChatImageDataSource {
    func updateChatImage(chatId: Int, image: UIImage?) -> Observable<Bool>
}

final class UpdateChatImageDataSourceImpl: UpdateChatImageDataSource {
    private let tokenDataSource: TokenDataSource
    
    init(tokenDataSource: TokenDataSource) {
        self.tokenDataSource = tokenDataSource
    }

    func updateChatImage(chatId: Int, image: UIImage?) -> RxSwift.Observable<Bool> {
        guard let base = Bundle.main.baseURL else {
            LoggerService.shared.log(level: .debug, "base 찾기 실패")
            return Observable.error(NetworkError.notFoundBaseURL)
        }
        let url = base + Endpoint.chatImage.endPoint+"\(chatId)/image"
        
        guard let token = tokenDataSource.getToken(for: .accessToken) else {
            return Observable.error(TokenError.notFoundAccessToken)
        }
    
        let headers: HTTPHeaders = [
            "AccessToken": token
        ]
        
        return Observable.create { observer in
            if let image {
                AF.upload(multipartFormData: { multipartFormData in
                    if let resizeImage = ImageLoadHelper.resizeImage(image, to: CGSize(width: 200, height: 200)), let jpegData = resizeImage.jpegData(compressionQuality: 0.2) {
 
                        multipartFormData.append(jpegData, withName: "chatRoomImage", fileName: "chatRoomImage.jpg", mimeType: "image/jpeg")
                    } else {
                        LoggerService.shared.log(level: .debug, "이미지 리사이징 실패")
                    }
                }, to: url, method: Endpoint.chatImage.requstType, headers: headers)
                .responseDecodable(of: StateResponseDTO.self) { response in
                    switch response.result {
                    case .success(let responseDTO):
                        observer.onNext(responseDTO.state)
                        observer.onCompleted()
                    case .failure(let error):
                        LoggerService.shared.log(level: .debug, "채팅방 이미지 수정 요청 실패 - \(error.localizedDescription)")
                        let statusCode = response.response?.statusCode ?? 0
                        observer.onError(NetworkError(serverStatusCode: statusCode))
                    }
                }
            } else {
                observer.onNext(false)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

