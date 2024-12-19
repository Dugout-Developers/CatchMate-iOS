//
//  ProfileImageHelper.swift
//  CatchMate
//
//  Created by 방유빈 on 8/21/24.
//

import UIKit
import Kingfisher

final class ProfileImageHelper {
    static func loadImage(_ profileImageView: UIImageView, pictureString: String?) {
        if let string = pictureString,
           let processedString = processString(string),
           let url = URL(string: processedString) {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "tempProfile"), options: nil, completionHandler: { result in
                switch result {
                case .success(_):
                    // 이미지 로드 성공
                    break
                case .failure(_):
                    // 이미지 로드 실패, 기본 이미지 설정
                    profileImageView.image = UIImage(named: "tempProfile")
                }
            })
        } else {
            profileImageView.image = UIImage(named: "tempProfile")
        }
    }

    private static func processString(_ string: String) -> String? {
        if isBase64Encoded(string),
           let data = Data(base64Encoded: string),
           let decodedString = String(data: data, encoding: .utf8) {
            // Base64 디코딩 성공
            return decodedString
        }
        // Base64가 아니면 원본 반환
        return string
    }

    private static func isBase64Encoded(_ string: String) -> Bool {
        // Base64 문자열인지 확인 (알파벳, 숫자, +, /, = 조합)
        let base64Regex = #"^[A-Za-z0-9+/=]+\Z"#
        return string.range(of: base64Regex, options: .regularExpression) != nil
    }
}
