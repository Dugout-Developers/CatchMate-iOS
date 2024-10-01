//
//  CatchMateTests.swift
//  CatchMateTests
//
//  Created by 방유빈 on 6/11/24.
//

import XCTest
@testable import CatchMate

final class DateHelperTests: XCTestCase {

    func testConvertISODateToCustomStrings_ValidDate() {
        // Given: 테스트할 ISO8601 형식의 문자열을 준비
        let isoDateString = "2024-08-16T00:00:00.000+00:00"
        
        // When: DateHelper의 메서드를 호출하여 결과를 받음
        let result = DateHelper.shared.convertISODateToCustomStrings(isoDateString: isoDateString)
        
        // Then: 결과가 예상한 값과 일치하는지 확인
        XCTAssertNotNil(result, "변환이 실패하면 안 됩니다.")
        XCTAssertEqual(result?.date, "08.16", "날짜 형식이 일치해야 합니다.")
        XCTAssertEqual(result?.playTime, "00:00", "시간 형식이 일치해야 합니다.")
    }
    
    func testConvertISODateToCustomStrings_InvalidDate() {
        // Given: 유효하지 않은 ISO8601 형식의 문자열을 준비
        let invalidISODateString = "Invalid-Date-String"
        
        // When: DateHelper의 메서드를 호출하여 결과를 받음
        let result = DateHelper.shared.convertISODateToCustomStrings(isoDateString: invalidISODateString)
        
        // Then: 변환이 실패하여 nil을 반환해야 함
        XCTAssertNil(result, "유효하지 않은 날짜 문자열은 nil을 반환해야 합니다.")
    }
}


