//
//  ApplyListModel.swift
//  CatchMate
//
//  Created by 방유빈 on 9/5/24.
//

import UIKit

struct Applys {
    let applys: [ApplyList]
    let isLast: Bool
}
struct ApplyList: Equatable {
    let enrollId: String
    let acceptStatus: ApplyStatus
    let addText: String
    let user: SimpleUser
    let post: SimplePost
    let new: Bool
    static func == (lhs: ApplyList, rhs: ApplyList) -> Bool {
        return lhs.enrollId == rhs.enrollId
    }
}

enum ApplyStatus: String {
    case accept = "ACCEPTED"
    case pending = "PENDING"
    case reject = "REJECTED"
}

struct RecivedApplies: Equatable, Comparable {
    let post: SimplePost
    var applies: [RecivedApplyData]
    
    static func == (lhs: RecivedApplies, rhs: RecivedApplies) -> Bool {
        return lhs.post.id == rhs.post.id && lhs.applies == rhs.applies
    }
    static func < (lhs: RecivedApplies, rhs: RecivedApplies) -> Bool {
        return lhs.post.id < rhs.post.id
    }
    static func > (lhs: RecivedApplies, rhs: RecivedApplies) -> Bool {
        return lhs.post.id > rhs.post.id
    }
    mutating func appendApply(apply: RecivedApplyData) {
        self.applies.append(apply)
    }
    mutating func changeNew() {
        for i in 0..<applies.count {
            applies[i].changeNewState() // 각 apply의 new 상태를 변경
        }
    }
}

struct RecivedApplyData: Equatable {
    let enrollId: String
    let user: SimpleUser
    let addText: String
    var new: Bool
    
    static func == (lhs: RecivedApplyData, rhs: RecivedApplyData) -> Bool {
        return lhs.enrollId == rhs.enrollId
    }
    
    mutating func changeNewState() {
        self.new = false
    }
}
