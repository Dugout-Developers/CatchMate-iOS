//
//  ApplyDataSourceTest.swift
//  CatchMateTests
//
//  Created by 방유빈 on 9/2/24.
//

import XCTest
import RxSwift
import Alamofire
import RxAlamofire

@testable import CatchMate
class MockTokenDataSource: TokenDataSource {
    func saveToken(token: String, for type: TokenType) -> Bool {
        return true
    }
    
    func getToken(for type: TokenType) -> String? {
        switch type {
        case .accessToken:
            return "Bearer eyJhbGciOiJIUzI1NiJ9.eyJpZCI6MTMsImV4cCI6MTcyNTQ2MTkzMn0.N2NOmJCLeJi75em_q0GycmtYY_DwMefAb0F4Xu-EAgQ"
        case .refreshToken:
            return "Bearer eyJhbGciOiJIUzI1NiJ9.eyJpZCI6MTMsImV4cCI6MTcyNjY0OTE5OH0.Av82NioYk49cYPKz_moQLRPnd9fmUdJT5jlL0OXIUPw"
        }
    }
    
    func deleteToken(for type: TokenType) -> Bool {
        return true
    }
    
    
}
final class ApplyDataSourceTest: XCTestCase {
    var disposeBag: DisposeBag!
    var dataSource: ApplyDataSource!
    
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        dataSource = ApplyDataSourceImpl(tokenDataSource: MockTokenDataSource())
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    func testApplyAPI() {
        let expectation = self.expectation(description: "Apply API Request")
        
        dataSource.applyPost(boardID: "16", addInfo: "테테테테테스트 테테테테테스형")
            .subscribe(onNext: { result in
                print(result)
                XCTAssertTrue(result > 0, "API 호출 결과로 0 이상의 결과가 반환됩니다.")
                expectation.fulfill()
            }, onError: { error in
                print("\(error.statusCode) - error.localizedDescription")
                XCTFail("API 호출이 실패했습니다: \(error)")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
