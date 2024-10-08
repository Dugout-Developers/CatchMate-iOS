//
//  Writer.swift
//  CatchMate
//
//  Created by 방유빈 on 8/15/24.
//

import Foundation
struct SimpleUser: Equatable {
    let userId: String
    let nickName: String
    let picture: String?
    let favGudan: Team
    let gender: Gender
    let birthDate: String ///1999-01-01
    let cheerStyle: CheerStyles?
    var birthData: Date? {
        return DateHelper.shared.toDate(from: birthDate, format: "YYYY-MM-dd")
    }
    
    var age: Int {
        guard let birthDate = birthData else {
            return 0 // 생년월일이 잘못된 경우 0을 반환
        }
        
        let calendar = Calendar.current
        let today = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: today)
        return ageComponents.year ?? 0
    }
    
    var ageRange: String {
        let ageRangeCalc = (age / 10) * 10
        return ageRangeCalc >= 50 ? "50대 이상" : "\(ageRangeCalc)대"
    }
    
    static func ==(lhs: SimpleUser, rhs: SimpleUser) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    init(userId: String, nickName: String, picture: String?, favGudan: Team, gender: Gender, birthDate: String, cheerStyle: CheerStyles?) {
        self.userId = userId
        self.nickName = nickName
        self.picture = picture
        self.favGudan = favGudan
        self.gender = gender
        self.birthDate = birthDate
        self.cheerStyle = cheerStyle
    }
    
    init(user: User) {
        self.userId = user.id
        self.nickName = user.nickName
        self.picture = user.profilePicture
        self.favGudan = user.team
        self.gender = user.gener
        self.birthDate = user.birth
        self.cheerStyle = user.cheerStyle
    }
    
    static var blockUsers: [SimpleUser] = [
        SimpleUser(userId: "1", nickName: "blockUser1", picture: "https://i.pinimg.com/236x/f1/ec/c8/f1ecc86b47a6e5789119afbbac06a4d4.jpg", favGudan: .hanhwa, gender: .man, birthDate: "1999-01-01", cheerStyle: nil),
        SimpleUser(userId: "2", nickName: "blockUser2", picture: "https://api.linkareer.com/community/attachments/77085", favGudan: .hanhwa, gender: .man, birthDate: "1999-01-01", cheerStyle: nil),
    ]
}
