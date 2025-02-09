//
//  ReceivedAppliesDTO\.swift
//  CatchMate
//
//  Created by 방유빈 on 2/9/25.
//

struct ReceivedAppliesDTO: Codable {
    let enrollInfoList: [EnrollInfo]
    let isLast: Bool
}

struct EnrollInfo: Codable {
    let boardInfo: PostListInfoDTO
    let enrollReceiveInfoList: [EnrollReceiveInfo]
}

struct EnrollReceiveInfo: Codable {
    let enrollId: Int
    let acceptStatus: String
    let description: String
    let requestDate: String
    let userInfo: UserInfo
    let isNew: Bool
    
    enum CodingKeys: String, CodingKey {
        case enrollId, acceptStatus, description, requestDate, userInfo
        case isNew = "new"
    }
}
