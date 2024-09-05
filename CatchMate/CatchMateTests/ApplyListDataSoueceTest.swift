//
//  ApplyListDataSoueceTest.swift
//  CatchMateTests
//
//  Created by 방유빈 on 9/3/24.
//

import XCTest
import RxSwift
import Alamofire
import RxAlamofire

@testable import CatchMate

final class ApplyListDataSoueceTest: XCTestCase {
    var disposeBag: DisposeBag!
    var sendDataSource: SendAppiesDataSource!
    var receiveDataSource: RecivedAppiesDataSource!
    
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        sendDataSource = SendAppiesDataSourceImpl(tokenDataSource: MockTokenDataSource())
        receiveDataSource = RecivedAppiesDataSourceImpl(tokenDataSource: MockTokenDataSource())
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    
    func testLoadSendListAPI() {
        let expectation = self.expectation(description: "Send Apply List Load API Request")
        let localDisposeBag = DisposeBag()
        
        self.sendDataSource.loadSendApplies()
            .subscribe(onNext: { result in
                print(result)
                XCTAssertTrue(result.count > 0, "API 호출 결과로 0 이상의 결과가 반환됩니다.")
                expectation.fulfill()
            }, onError: { error in
                print("\(error.localizedDescription)")
                XCTFail("API 호출이 실패했습니다: \(error)")
                expectation.fulfill()
            })
            .disposed(by: localDisposeBag)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoadRecievedListApI() {
        let expectation = self.expectation(description: "Recieved Apply List Load API Request")
        
        self.receiveDataSource.loadRecivedApplies(boardId: 5)
            .subscribe(onNext: { result in
                print(result)
                XCTAssertTrue(result.count > 0, "API 호출 결과로 0 이상의 결과가 반환됩니다.")
                expectation.fulfill()
            }, onError: { error in
                print("\(error.localizedDescription)")
                XCTFail("API 호출이 실패했습니다: \(error)")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
