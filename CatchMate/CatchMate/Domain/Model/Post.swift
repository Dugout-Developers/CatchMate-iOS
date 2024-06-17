//
//  Post.swift
//  CatchMate
//
//  Created by 방유빈 on 6/17/24.
//

import UIKit

struct Post: Identifiable {
    var id: String = UUID().uuidString
    let title: String
    let writer: User
    let homeTeam: Team
    let awayTeam: Team
    let playTime: String
}
