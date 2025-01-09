//
//  EndPoint.swift
//  CatchMate
//
//  Created by 방유빈 on 1/9/25.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

enum Endpoint {
    /// 로그인
    case login
    /// 로그아웃
    case logout
    /// 회원가입
    case signUp
    /// 게시글 저장
    case savePost
    /// 게시글 임시 저장
    case tempPost
    /// 게시글 수정
    case editPost
    /// 게시글 리스트
    case postlist
    /// user 게시글 조회
    case userPostlist
    /// 게시글 조회
    case loadPost
    /// 게시글 끌어올리기
    case upPost
    /// 게시글 삭제
    case removePost
    /// 찜목록 조회
    case loadFavorite
    /// 찜 설정
    case setFavorite
    /// 찜삭제
    case deleteFavorite
    /// 알람 설정
    case setNotification
    
    /// 직관 신청
    case apply
    /// 직관 신청 취소
    case cancelApply
    /// 보낸 직관 신청 목록
    case sendApply
    /// 받은 직관 신청 목록
    case receivedApply
    /// 받은 직관 신청 전체 목록
    case receivedApplyAll
    /// 받은 직관 신청 미확인 갯수
    case receivedCount
    /// 직관 신청 수락
    case acceptApply
    /// 직관 신청 거절
    case rejectApply
    
    /// 내정보 조회
    case loadMyInfo
    /// 내정보 수정
    case editProfile
    
    /// 알림 리스트 조회
    case notificationList
    /// 알림 삭제
    case deleteNoti
    
    var endPoint: String {
        switch self {
        case .login:
            return "/auth/login"
        case .logout:
            return "/auth/logout"
        case .signUp:
            return "/user/additional-info"
        case .savePost, .tempPost:
            return "/board"
        case .editPost:
            return "/board/"
        case .postlist:
            return "/board/list"
        case .userPostlist:
            return "/board/list/"
        case .loadPost, .removePost:
            /// 게시글 조회, 삭제 /board/{boardId}
            return "/board/"
        case .upPost:
            /// 끌어올리기 /board/{boardId}/lift-up
            return "/board/"
        case .loadFavorite:
            return "/board/bookmark"
        case .setFavorite, .deleteFavorite:
            /// 찜 설정 /board/bookmark/{boardID}
            return "/board/bookmark/"
        case .setNotification:
            return "/user/alarm"
        case .apply:
            /// 직관 신청 /enroll/{boardId}
            return "/enroll/"
        case .cancelApply:
            return "/enroll/cancel/"
        case .sendApply:
            return "/enroll/request"
        case .receivedApply:
            return "/enroll/receive"
        case .receivedApplyAll:
            return "/enroll/receive/all"
        case .receivedCount:
            return "/enroll/new-count"
        case .acceptApply, .rejectApply:
            /// acceptApply = /enroll/{enrollId}/accept
            /// rejectApply = /enroll/{enrollId}/reject
            return "/enroll/"
        case .loadMyInfo:
            return "/user/profile"
        case .editProfile:
            return "/user/profile"
        case .notificationList:
            return "/notification/receive"
        case .deleteNoti:
            return "/notification/receive/"
        }
    }
    var apiName: String {
        switch self {
        case .login:
            return "로그인 API"
        case .logout:
            return "로그아웃 API"
        case .signUp:
            return "회원가입 API"
        case .savePost:
            return "게시글 저장 API"
        case .tempPost:
            return "게시글 임시 저장 API"
        case .editPost:
            return "게시글 수정 API"
        case .postlist:
            return "게시글 리스트 불러오기 API"
        case .loadPost:
            return "게시글 로드 API"
        case .upPost:
            return "게시글 끌어올리기 API"
        case .removePost:
            return "게시글 삭제 API"
        case .userPostlist:
            return "유저 게시글 리스트 로드 API"
        case .loadFavorite:
            return "찜목록 로드 API"
        case .setFavorite:
            return "찜하기 API"
        case .deleteFavorite:
            return "찜 삭제 API"
        case .setNotification:
            return "알람 설정 API"
        case .apply:
            return "직관 신청 API"
        case .cancelApply:
            return "직관 신청 취소 API"
        case .sendApply:
            return "보낸 신청 목록 API"
        case .receivedApply:
            return "받은 신청 목록 API"
        case .receivedApplyAll:
            return "받은 신청 전체 목록 API"
        case .receivedCount:
            return "미확인 받은 신청 개수 API"
        case .acceptApply:
            return "직관 신청 수락 API"
        case .rejectApply:
            return "직관 신청 거절 API"
        case .loadMyInfo:
            return "내 정보 조회 API"
        case .editProfile:
            return "내 정보 수정 API"
        case .notificationList:
            return "알림 리스트 조회 API"
        case .deleteNoti:
            return "받은 알림 삭제 API"
        }
    }
    
    var requstType: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .logout:
            return .delete
        case .signUp:
            return .post
        case .savePost, .tempPost:
            return .post
        case .editPost:
            return .patch
        case .setNotification:
            return .patch
        case .loadPost:
            return .get
        case .upPost:
            return .patch
        case .removePost:
            return .delete
        case .userPostlist:
            return .get
        case .loadFavorite:
            return .get
        case .setFavorite:
            return .post
        case .deleteFavorite:
            return .delete
        case .postlist:
            return .get
        case .apply:
            return .post
        case .cancelApply:
            return .delete
        case .sendApply:
            return .get
        case .receivedApply:
            return .get
        case .receivedApplyAll:
            return .get
        case .receivedCount:
            return .get
        case .acceptApply:
            return .patch
        case .rejectApply:
            return .patch
        case .loadMyInfo:
            return .get
        case .editProfile:
            return .patch
        case .notificationList:
            return .get
        case .deleteNoti:
            return .delete
        }
    }
}
