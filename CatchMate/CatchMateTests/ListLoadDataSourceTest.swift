//
//  ListLoadDataSourceTest.swift
//  CatchMateTests
//
//  Created by 방유빈 on 8/29/24.
//

import XCTest
import RxSwift
import Alamofire
import RxAlamofire

@testable import CatchMate

final class ListLoadDataSourceTest: XCTestCase {
    var disposeBag: DisposeBag!
    var dataSource: PostListLoadDataSource!
    var listLoadDataSource: LoadFavoriteListDataSource!

    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        dataSource = PostListLoadDataSourceImpl() // 실제 데이터 소스
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    func testDefaultsFilter() {
        let expectation = self.expectation(description: "Post Load API Request - DefaultsFilter")
        dataSource.loadPostList(pageNum: 1, gudan: "", gameDate: "", people: 0)
            .subscribe (onNext: { result in
                print(result)
                XCTAssertFalse(!result.isEmpty, "API 호출 결과로 빈 목록이 아닌 값이 반환됩니다.")
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
    
    func testNumberFilter() {

    }
    
    func testGudanFilter() {
        
    }
    
    func testDateFilter() {
        
    }
    
    func testAllFilter() {
        
    }
    
}
