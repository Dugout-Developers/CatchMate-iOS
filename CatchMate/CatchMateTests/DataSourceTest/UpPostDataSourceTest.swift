//
//  UpPostDataSourceTest.swift
//  CatchMate
//
//  Created by 방유빈 on 11/14/24.
//

import XCTest
import RxSwift
import Alamofire
import RxAlamofire

@testable import CatchMate

final class UpPostDataSourceTest: XCTestCase {
    var disposeBag: DisposeBag!
    var dataSource: UpPostDataSource!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        dataSource = UpPostDataSourceImpl(tokenDataSource: MockTokenDataSource())
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    func tesUpPostAPI() {
        let expectation = self.expectation(description: "Up Post API Request")
        
        dataSource.upPost(8)
            .subscribe(onNext: { result in
                XCTAssertTrue(result)
                expectation.fulfill()
            }, onError: { error in
                if let afError = error as? AFError {
                    switch afError {
                    case .invalidURL(let url):
                        print("Invalid URL: \(url)")
                    case .parameterEncodingFailed(let reason):
                        print("Parameter encoding failed: \(reason)")
                    case .multipartEncodingFailed(let reason):
                        print("Multipart encoding failed: \(reason)")
                    case .responseValidationFailed(let reason):
                        print("Response validation failed: \(reason)")
                        if let underlyingError = afError.underlyingError {
                            print("Underlying error: \(underlyingError)")
                        }
                    case .responseSerializationFailed(let reason):
                        print("Response serialization failed: \(reason)")
                    default:
                        print("AFError occurred: \(afError)")
                    }
                } else {
                    print("Other error occurred: \(error)")
                }
                XCTFail("API 호출이 실패했습니다: \(error)")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
