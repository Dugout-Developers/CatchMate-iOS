//
//  FavoriteTest.swift
//  CatchMateTests
//
//  Created by 방유빈 on 8/22/24.
//

import XCTest
import RxSwift
import Alamofire
import RxAlamofire

@testable import CatchMate

final class FavoriteTest: XCTestCase {
    var disposeBag: DisposeBag!
    var dataSource: SetFavoriteDataSource!
    var listLoadDataSource: LoadFavoriteListDataSource!

    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        dataSource = SetFavoriteDataSourceImpl(tokenDataSource: MockTokenDataSource()) // 실제 데이터 소스
        listLoadDataSource = LoadFavoriteListDataSourceImpl(tokenDataSource: MockTokenDataSource())
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
    
    func testFavoriteListLoadAPI() {
        let expectation = self.expectation(description: "FavoriteList Load API Request")
        listLoadDataSource.loadFavoriteList()
            .subscribe (onNext: { result in
                // 빈 배열일 경우와 값이 있는 배열일 경우 모두 처리
                if result.isEmpty {
                    print("빈 배열이 반환되었습니다.")
                    XCTAssertTrue(result.isEmpty, "빈 배열이 반환되어야 합니다.")
                } else {
                    print("PostListDTO 배열이 반환되었습니다: \(result)")
                    XCTAssertFalse(result.isEmpty, "배열에 데이터가 있어야 합니다.")
                    // 추가적으로 배열의 첫 번째 요소에 대한 검증을 할 수 있습니다.
                    // 예: XCTAssertEqual(result.first?.id, expectedId)
                }
                expectation.fulfill()
            }, onError:{ error in
                XCTFail("API 호출이 실패했습니다: \(error)")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}

class FavoriteListLoadDataSourceMock: LoadFavoriteListDataSource {
    func loadFavoriteList() -> RxSwift.Observable<[PostListDTO]> {
        // 목업 데이터를 그대로 반환
        return Observable.just(listLoaddataSourceMockUpData)
    }
    
    var listLoaddataSourceMockUpData: [PostListDTO] = [
        PostListDTO(boardId: 1, title: "잠실에 원터 보러 가실 분~", gameDate: "2024-08-12T18:00:00.000+00:00", location: "잠실", homeTeam: "두산", awayTeam: "한화", cheerTeam: "한화", currentPerson: 2, maxPerson: 4),
        PostListDTO(boardId: 13, title: "야구 직관 모임", gameDate: "2024-08-12T18:00:00.000+00:00", location: "잠실", homeTeam: "두산", awayTeam: "한화", cheerTeam: "한화", currentPerson: 3, maxPerson: 4)
    ]
    
}

final class FavoriteRepositoryTest: XCTestCase {
    var disposeBag: DisposeBag!
    var listLoadDataSource: LoadFavoriteListDataSource!
    var listLoadRepository: LoadFavoriteListRepository!
    var mockDataSource: FavoriteListLoadDataSourceMock!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        mockDataSource = FavoriteListLoadDataSourceMock()
        listLoadRepository = LoadFavoriteListRepositoryImpl(loadFavorioteListDS: mockDataSource)
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    func testFavoriteListMapping() {
        let expectation = self.expectation(description: "Repository Data Mapping Test")
        
        listLoadRepository.loadFavoriteList()
            .subscribe { result in
                print(result)
                // 3. 검증: 레포지토리가 데이터 소스에서 받은 데이터를 올바르게 처리했는지 확인
                XCTAssertEqual(result.count, 2, "목록에 두 개의 항목이 있어야 합니다.")
                XCTAssertEqual(result[0].id, "1", "첫 번째 게시물의 boardId가 일치해야 합니다.")
                XCTAssertEqual(result[1].title, "야구 직관 모임", "두 번째 게시물의 제목이 일치해야 합니다.")
                expectation.fulfill()
            } onError: { error in
                XCTFail("레포지토리 테스트 중 에러 발생: \(error)")
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
           

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testEmptyFavoriteListMapping() {
        let expectation = self.expectation(description: "Repository Empty Data Mapping Test")
        mockDataSource.listLoaddataSourceMockUpData = []
        listLoadRepository.loadFavoriteList()
            .subscribe { result in
                XCTAssertTrue(result.isEmpty, "목록이 비어 있어야 합니다.")
                expectation.fulfill()
            } onError: { error in
                XCTFail("레포지토리 테스트 중 에러 발생: \(error)")
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
        waitForExpectations(timeout: 5, handler: nil)
    }
}
