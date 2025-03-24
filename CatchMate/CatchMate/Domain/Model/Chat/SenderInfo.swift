//
//  SenderInfo.swift
//  CatchMate
//
//  Created by 방유빈 on 2/4/25.
//

import Foundation

struct SenderInfo: Equatable {
    let senderId: Int
    let nickName: String
    let imageUrl: String
    
    static func == (lhs: SenderInfo, rhs: SenderInfo) -> Bool {
        return lhs.senderId == rhs.senderId  // ✅ senderId만 비교
    }
}
