//
//  PostIsFinishGameTest.swift
//  CatchMate
//
//  Created by 방유빈 on 4/8/25.
//

import XCTest
import UIKit
import Kingfisher

@testable import CatchMate
final class PostIsFinishGameTest: XCTestCase {
    var dateStrings: [(String, Bool)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")

        let now = Date()
        let calendar = Calendar.current

        return [
            (calendar.date(byAdding: .day, value: -2, to: now), true),
            (calendar.date(byAdding: .day, value: -1, to: now), true),
            (calendar.date(byAdding: .hour, value: -1, to: now), true),
            (calendar.date(byAdding: .minute, value: -1, to: now), true),
            (calendar.date(byAdding: .minute, value: 1, to: now), false),
            (calendar.date(byAdding: .hour, value: 1, to: now), false),
            (calendar.date(byAdding: .day, value: 1, to: now), false),
            (calendar.date(byAdding: .day, value: 7, to: now), false)
        ]
        .compactMap { date, expected in
            guard let date else { return nil }
            return (formatter.string(from: date), expected)
        }
    }

    func testIsFinishGame() {
        for (dateString, expected) in dateStrings {
            let post = Post(
                id: "1",
                title: "",
                writer: SimpleUser(userId: 1, nickName: "", picture: "", favGudan: .allTeamLove, gender: .man, birthDate: "", cheerStyle: nil),
                homeTeam: .dosun,
                awayTeam: .hanhwa,
                cheerTeam: .dosun,
                date: "",
                playTime: "",
                location: "",
                maxPerson: 4,
                currentPerson: 3,
                preferGender: nil,
                preferAge: [],
                addInfo: "",
                chatRoomId: 1,
                gameDateString: dateString
            )

            print("📅 테스트 시간: \(dateString)")
            print("⏱ 현재 시간: \(Date())")
            print("결과: \(post.isFinishGame), 기대값: \(expected)")

            XCTAssertEqual(post.isFinishGame, expected, "❗️결과 값이 \(expected)이여야 합니다.")
        }

    }
}
