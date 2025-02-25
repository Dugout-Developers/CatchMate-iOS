//
//  UserDefaultsKeys.swift
//  CatchMate
//
//  Created by 방유빈 on 8/28/24.
//

import Foundation

enum UserDefaultsKeys {
    enum SetupInfo {
        enum UserInfo {
            static let id = "UserId"
            static let email = "UserEmail"
            static let team = "UserFavoriteTeam"
            static let nickName = "UserNickName"
            static let imageUrl = "UserImageUrl"
        }
    }
    enum ChatInfo {
        static let chatRoomId = "ChatRoomId"
    }
    
    enum AlarmSetup {
        static let alarmSetup = "hasRequestedNotification"
    }
}
