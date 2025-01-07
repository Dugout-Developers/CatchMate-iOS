//
//  ProfileEditRequestDTO.swift
//  CatchMate
//
//  Created by 방유빈 on 12/12/24.
//
import UIKit

struct ProfileEditRequestDTO {
    let request: Request
    let profileImage: UIImage
    
    struct Request: Codable {
        let nickName: String
        let favoriteClubId: Int
        let watchStyle: String
    }
}
