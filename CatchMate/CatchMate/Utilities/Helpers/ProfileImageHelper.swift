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
        if let string = pictureString, let url = URL(string: string) {
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
}
