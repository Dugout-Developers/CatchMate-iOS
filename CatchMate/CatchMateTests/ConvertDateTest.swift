//
//  ConvertDateTest.swift
//  CatchMate
//
//  Created by 방유빈 on 1/3/25.
//

import XCTest
import UIKit
import Kingfisher

@testable import CatchMate
final class ConvertDateTest: XCTestCase {
    let dateString = "2025-01-24T18:30:00"
    
    func testConvertISODateToCustomStrings() {
        let result = DateHelper.shared.convertISODateToCustomStrings(isoDateString: dateString)
        print("Test: \(result)")
        XCTAssertNotNil(result, "결과값이 nil이면 안됩니다.")
        XCTAssertEqual(result?.date, "01.24", "변환한 값의 date 변수는 MM.DD 형식이여야합니다.")
        XCTAssertEqual(result?.playTime, "18:30", "변환한 값의 playTime 변수는 HH:mm 형식이여야합니다.")
    }
}
