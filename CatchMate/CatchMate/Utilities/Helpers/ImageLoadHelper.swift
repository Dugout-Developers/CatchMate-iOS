//
//  ProfileImageHelper.swift
//  CatchMate
//
//  Created by 방유빈 on 8/21/24.
//

import UIKit
import Kingfisher
import RxSwift

final class ImageLoadHelper {
    static func loadImage(_ profileImageView: UIImageView, pictureString: String?, defaultImage: UIImage? = UIImage(named: "defaultImage")!) {
        if let string = pictureString,
           let processedString = processString(string),
           let url = URL(string: processedString) {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "def"), options: nil, completionHandler: { result in
                switch result {
                case .success(_):
                    // 이미지 로드 성공
                    break
                case .failure(_):
                    // 이미지 로드 실패, 기본 이미지 설정
                    profileImageView.image = defaultImage
                }
            })
        } else {
            profileImageView.image = defaultImage
        }
    }
    
    static func urlToUIImage(_ imageString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: imageString) else {
            print("잘못된 URL")
            completion(nil)
            return
        }
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                completion(value.image)
            case .failure:
                completion(nil)
            }
        }
    }
    
    static func urlToUIImage(_ imageString: String) -> Single<UIImage?> {
        return Single<UIImage?>.create { single in
            guard let url = URL(string: imageString) else {
                print("잘못된 URL")
                single(.success(nil))
                return Disposables.create()
            }

            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    single(.success(value.image))
                case .failure:
                    single(.success(nil))
                }
            }

            return Disposables.create()
        }
    }

    static func processString(_ string: String) -> String? {
        if isBase64Encoded(string) {
            if let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters),
                let decodedString = String(data: data, encoding: .utf8) {
                    // Base64 디코딩 성공
                    return decodedString
            } else {
                return nil
            }
        }
        // Base64가 아니면 원본 반환
        return string
    }

    static func isBase64Encoded(_ string: String) -> Bool {
        // Base64 문자열인지 확인 (알파벳, 숫자, +, /, = 조합)
        let base64Regex = #"^[A-Za-z0-9+/=]+\Z"#
        return string.range(of: base64Regex, options: .regularExpression) != nil
    }
    
    /// 이미지 -> Base64 문자열 변환
    static func convertImageToBase64String(image: UIImage?) -> String? {
        guard let image else { return "" }
        guard let resizeImage = resizeImage(image, to: CGSize(width: 150, height: 150)), let imageData = resizeImage.jpegData(compressionQuality: 0.2) else { return nil }
        return imageData.base64EncodedString()
    }
    
    static func resizeImage(_ image: UIImage, to targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
