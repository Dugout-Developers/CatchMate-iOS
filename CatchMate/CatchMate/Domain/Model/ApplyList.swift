//
//  ApplyListModel.swift
//  CatchMate
//
//  Created by 방유빈 on 9/5/24.
//

import UIKit

struct ApplyList {
    let enrollId: String
    let acceptStatus: ApplyStatus
    let addText: String
    let user: SimpleUser
    let post: SimplePost
}

enum ApplyStatus: String {
    case accept = "ACCEPT"
    case pending = "PENDING"
    case reject = "REJECTED"
}
