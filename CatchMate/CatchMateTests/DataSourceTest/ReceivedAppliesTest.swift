//
//  ReceivedAppliesTest.swift
//  CatchMateTests
//
//  Created by 방유빈 on 9/10/24.
//

import XCTest
import RxSwift
import Alamofire
import RxAlamofire

@testable import CatchMate

final class ReceivedAppliesTest: XCTestCase {
    var disposeBag: DisposeBag!
    var receiveDataSource: RecivedAppiesDataSource!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        receiveDataSource = RecivedAppiesDataSourceImpl(tokenDataSource: MockTokenDataSource())
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    func testLoadPostId() {
        let postId = 1
        let expectation = self.expectation(description: "Received \(postId)Post Apply List Load API Request")
        self.receiveDataSource.loadRecivedApplies(boardId: postId)
            .subscribe (onNext: { result in
                print(result)
                XCTAssertTrue(result.count > 0, "API 호출 결과로 0 이상의 결과가 반환됩니다.")
            }, onError: { error in
                print("\(error.localizedDescription)")
                XCTFail("API 호출이 실패했습니다: \(error)")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 10, handler: nil)

    }
    
    func testloadAll() {
        let expectation = self.expectation(description: "Received Apply All List Load API Request")
        
        self.receiveDataSource.loadReceivedAppliesAll()
            .subscribe (onNext: { result in
                print(result)
                XCTAssertTrue(result.count > 0, "API 호출 결과로 0 이상의 결과가 반환됩니다.")
            }, onError: { error in
                print("\(error.localizedDescription)")
                XCTFail("API 호출이 실패했습니다: \(error)")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
