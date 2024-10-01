//
//  LoadPostDetailDataSourceTests.swift
//  CatchMateTests
//
//  Created by 방유빈 on 8/31/24.
//

import XCTest
import RxSwift
import Alamofire
import RxAlamofire

@testable import CatchMate

final class LoadPostDetailDataSourceTests: XCTestCase {
    var disposeBag: DisposeBag!
    var dataSource: LoadPostDataSource!

    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        dataSource = LoadPostDataSourceImpl(tokenDataSource: MockTokenDataSource())
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    func testLoadPostDetailDataSource() {
        let mockupPostIds = Array(1...85)
        
        let expectations = mockupPostIds.map { id in
            expectation(description: "Post Load API Request for postId: \(id)")
        }
        
        for (index, id) in mockupPostIds.enumerated() {
            let delay = DispatchTime.now() + Double(index) * 0.5
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.dataSource.laodPost(postId: id)
                    .subscribe(onNext: { result in
                        LoggerService.shared.debugLog("\(id) 호출 결과: \(result)")
                        XCTAssertTrue(result.boardId == id, "\(id) 호출 결과가 기대한 값과 다릅니다.")
                        expectations[index].fulfill()
                    }, onError: { error in
                        LoggerService.shared.debugLog("\(id) 호출 오류 : \(error)")
                        expectations[index].fulfill()
                    })
                    .disposed(by: self.disposeBag)
            }
        }
        
        wait(for: expectations, timeout: 80 * 0.5 + 10)
    }
}


