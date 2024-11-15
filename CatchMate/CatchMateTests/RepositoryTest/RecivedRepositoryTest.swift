////
////  RecivedRepositoryTest.swift
////  CatchMateTests
////
////  Created by 방유빈 on 10/1/24.
////
//import XCTest
//import RxSwift
//import Alamofire
//import RxAlamofire
//
//@testable import CatchMate
//
//final class RecivedRepositoryTest: XCTestCase {
//    var disposeBag: DisposeBag!
//    var repository: RecivedAppiesRepository!
//    override func setUp() {
//        super.setUp()
//
//        let mockupDataSource = MockupRecivedAppliesDataSource()
//        repository = RecivedAppliesRepositoryImpl(recivedAppliesDS: mockupDataSource)
//        disposeBag = DisposeBag()
//    }
//    
//    override func tearDown() {
//        disposeBag = nil
//        super.tearDown()
//    }
//
//    func testloadAllApplies() {
//        let expectation = self.expectation(description: "Received All Applies Repository Test")
//
//        let expectedData: [RecivedApplies] = [
//            RecivedApplies(post: SimplePost(id: "1", title: "title", homeTeam: .hanhwa, awayTeam: .ssg, cheerTeam: .hanhwa, date: "09.29", playTime: "18:00", location: "대전", maxPerson: 3, currentPerson: 1), applies: [
//                RecivedApplyData(enrollId: "1", user: SimpleUser(userId: "1", nickName: "aa", picture: "", favGudan: .hanhwa, gender: .woman, birthDate: "2000-01-22", cheerStyle: .director), addText: "asd"),
//                RecivedApplyData(enrollId: "2", user: SimpleUser(userId: "2", nickName: "22", picture: "", favGudan: .hanhwa, gender: .woman, birthDate: "2000-01-22", cheerStyle: .cheerleader), addText: "asd")
//            ]),
//            RecivedApplies(post: SimplePost(id: "2", title: "title", homeTeam: .hanhwa, awayTeam: CatchMateTests.Team.nc, cheerTeam: .hanhwa, date: "09.29", playTime: "17:00", location: "대전", maxPerson: 3, currentPerson: 1), applies: [
//                RecivedApplyData(enrollId: "3", user: SimpleUser(userId: "2", nickName: "22", picture: "", favGudan: .hanhwa, gender: .woman, birthDate: "2000-01-22", cheerStyle: .cheerleader), addText: "asd"),
//                RecivedApplyData(enrollId: "4", user: SimpleUser(userId: "3", nickName: "33", picture: "", favGudan: .hanhwa, gender: .woman, birthDate: "2000-01-22", cheerStyle: .eatLove), addText: "asd")
//            ])
//        ]
//        self.repository.loadReceivedAppliesAll()
//            .subscribe (onNext: { result in
//                print("Result: \(result)")
//                print("Expected: \(expectedData)")
//                XCTAssertEqual(result, expectedData)
//                expectation.fulfill()
//            }, onError: { error in
//                XCTFail("API 호출이 실패했습니다: \(error)")
//                expectation.fulfill()
//            })
//            .disposed(by: disposeBag)
//        
//        // 최대 5초까지 비동기 요청 대기
//        waitForExpectations(timeout: 5, handler: nil)
//    }
//}
//
//final class MockupRecivedAppliesDataSource: RecivedAppiesDataSource {
//    func loadRecivedApplies(boardId: Int) -> RxSwift.Observable<[Content]> {
//        let mockupData = [
//            Content(enrollId: 1, acceptStatus: "PENDING", description: "asd", userInfo: UserInfo(userId: 1, nickName: "aa", picture: "", favGudan: "이글스", watchStyle: "감독", gender: "F", birthDate: "2000-01-22"), boardInfo: BoardInfo(boardId: boardId, title: "title", gameDate: "2024-09-29T18:00:00.000+00:00", location: "대전", homeTeam: "이글스", awayTeam: "랜더스", currentPerson: 1, maxPerson: 3, addInfo: "ㅇㅇㅇㅇ"), new: false),
//            Content(enrollId: 2, acceptStatus: "PENDING", description: "asd", userInfo: UserInfo(userId: 2, nickName: "22", picture: "", favGudan: "이글스", watchStyle: "응원단장", gender: "F", birthDate: "2000-01-22"), boardInfo: BoardInfo(boardId: boardId, title: "title", gameDate: "2024-09-29T18:00:00.000+00:00", location: "대전", homeTeam: "이글스", awayTeam: "랜더스", currentPerson: 1, maxPerson: 3, addInfo: "ㅇㅇㅇㅇ"), new: true)
//        ]
//        return Observable.just(mockupData)
//    }
//    
//    func loadReceivedAppliesAll() -> RxSwift.Observable<[Content]> {
//        let mockupData = [
//            Content(enrollId: 1, acceptStatus: "PENDING", description: "asd", userInfo: UserInfo(userId: 1, nickName: "aa", picture: "", favGudan: "이글스", watchStyle: "감독", gender: "F", birthDate: "2000-01-22"), boardInfo: BoardInfo(boardId: 1, title: "title", gameDate: "2024-09-29T18:00:00.000+00:00", location: "대전", homeTeam: "이글스", awayTeam: "랜더스", currentPerson: 1, maxPerson: 3, addInfo: "ㅇㅇㅇㅇ"), new: false),
//            Content(enrollId: 2, acceptStatus: "PENDING", description: "asd", userInfo: UserInfo(userId: 2, nickName: "22", picture: "", favGudan: "이글스", watchStyle: "응원단장", gender: "F", birthDate: "2000-01-22"), boardInfo: BoardInfo(boardId: 1, title: "title", gameDate: "2024-09-28T17:00:00.000+00:00", location: "대전", homeTeam: "이글스", awayTeam: "랜더스", currentPerson: 1, maxPerson: 3, addInfo: "ㅇㅇㅇㅇ"), new: false),
//            Content(enrollId: 3, acceptStatus: "PENDING", description: "asd", userInfo: UserInfo(userId: 2, nickName: "22", picture: "", favGudan: "이글스", watchStyle: "응원단장", gender: "F", birthDate: "2000-01-22"), boardInfo: BoardInfo(boardId: 2, title: "title", gameDate: "2024-09-29T17:00:00.000+00:00", location: "대전", homeTeam: "이글스", awayTeam: "다이노스", currentPerson: 1, maxPerson: 3, addInfo: "ㅇㅇㅇㅇ"), new: true),
//            Content(enrollId: 4, acceptStatus: "PENDING", description: "asd", userInfo: UserInfo(userId: 3, nickName: "33", picture: "", favGudan: "이글스", watchStyle: "먹보", gender: "F", birthDate: "2000-01-22"), boardInfo: BoardInfo(boardId: 2, title: "title", gameDate: "2024-09-29T17:00:00.000+00:00", location: "대전", homeTeam: "이글스", awayTeam: "다이노스", currentPerson: 1, maxPerson: 3, addInfo: "ㅇㅇㅇㅇ"), new: true)
//        ]
//        return Observable.just(mockupData)
//    }
//    
//    
//}
