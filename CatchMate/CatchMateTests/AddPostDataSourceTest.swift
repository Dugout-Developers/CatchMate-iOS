//
//  AddPostDataSourceTest.swift
//  CatchMateTests
//
//  Created by 방유빈 on 8/30/24.
//

import XCTest
import RxSwift
import Alamofire
import RxAlamofire

@testable import CatchMate

final class AddPostDataSourceTest: XCTestCase {
    var disposeBag: DisposeBag!
    var dataSource: AddPostDataSource!

    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        dataSource = AddPostDataSourceImpl(tokenDataSource: MockTokenDataSource())
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    func testDefaultsFilter() {
        let expectation = self.expectation(description: "Post Load API Request - DefaultsFilter")
        let mockupPost = AddPostRequsetDTO(title: "주황 이글스?", gameDate: "2024-08-31 18:00:00", location: "대전", homeTeam: "이글스", awayTeam: "위즈", cheerTeam: "이글스", maxPerson: 2, preferGender: "F", preferAge: 25, addInfo: "주황이 근본이긴 해~")
        dataSource.addPost(mockupPost)
            .subscribe (onNext: { result in
                print(result)
                XCTAssertTrue(result > 0, "API 호출 결과로 0보다 큰 boardId값이 출력됩니다.")
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

