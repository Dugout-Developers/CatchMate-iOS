//
//  SetFavoriteDataSourceTest.swift
//  CatchMateTests
//
//  Created by 방유빈 on 9/1/24.
//

import XCTest
import RxSwift
import Alamofire
import RxAlamofire

@testable import CatchMate

final class SetFavoriteDataSourceTest: XCTestCase {
    var disposeBag: DisposeBag!
    var dataSource: SetFavoriteDataSource!
    
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        dataSource = SetFavoriteDataSourceImpl()
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    func testFavprotePostAPI() {
        let expectation = self.expectation(description: "API Request")
        
        dataSource.setFavorite(true, "2")
            .subscribe(onNext: { result in
                print(result)
                XCTAssertFalse(result, "API 호출 결과로 true가 반환됩니다.")
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
