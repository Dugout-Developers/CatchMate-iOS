//
//  Apply.swift
//  CatchMate
//
//  Created by 방유빈 on 7/17/24.
//

import UIKit

struct ApplyRequest {
    let applyPostId: String
    let addInfo: String?
}

struct MyApplyInfo {
    let enrollId: Int
    let addInfo: String
}

struct Apply: Equatable {
    let id: String
    let post: Post
    let applicant: User
    let addText: String?
    let applyDate: Date = Date()
    
    static func == (lhs: Apply, rhs: Apply) -> Bool {
        return lhs.id == rhs.id
    }
}

