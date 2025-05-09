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
    /// 탈퇴하기
    case withdraw
    /// 회원가입
    case signUp
    /// 게시글 저장
    case savePost
    /// 게시글 임시 저장
    case tempPost
    /// 임시저장 게시글 불러오기
    case loadTempPost
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
    /// 보낸 신청 디테일
    case sendApplyDetail
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
    
    /// 채팅 리스트 조회
    case chatList
    /// 채팅방 유저 조회
    case chatUsers
    /// 채팅방 이전 메시지 조회
    case chatMessage
    /// 채팅방 이미지 수정
    case chatImage
    /// 채팅방 나가기
    case exitChat
    /// 채팅방 유저 강퇴
    case exportChatUser
    /// 채팅방 1개 정보 조회
    case chatDetail
    /// 채팅방 개별 알림 설정
    case chatRoomNotification
    
    /// 내정보 조회
    case loadMyInfo
    /// 내정보 수정
    case editProfile
    /// 안읽은 메시지 여부
    case unreadMessage
    
    /// 알림 리스트 조회
    case notificationList
    /// 알림 단일 조회
    case notification
    /// 알림 삭제
    case deleteNoti
    
    /// 유저 신고
    case report
    /// 차단 유저 목록 조회
    case blockUserList
    /// 유저 차단
    case blockUser
    /// 유저 차단 해제
    case unBlockUser
    
    /// 문의하기
    case inquiries
    /// 문의하기 답변 디테일
    case inquiryDetail
    /// 공지사항 리스트
    case noticesList
    
    var endPoint: String {
        switch self {
        case .login:
            return "/auth/login"
        case .logout:
            return "/auth/logout"
        case .withdraw:
            return "/users/withdraw"
        case .signUp:
            return "/users/additional-info"
        case .savePost, .tempPost:
            return "/boards"
        case .loadTempPost:
            return "/boards/temp"
        case .editPost:
            return "/boards/"
        case .postlist:
            return "/boards/list"
        case .userPostlist:
            return "/boards/list/"
        case .loadPost, .removePost:
            /// 게시글 조회, 삭제 /board/{boardId}
            return "/boards/"
        case .upPost:
            /// 끌어올리기 /board/{boardId}/lift-up
            return "/boards/"
        case .loadFavorite:
            return "/boards/bookmark"
        case .setFavorite, .deleteFavorite:
            /// 찜 설정 /board/bookmark/{boardID}
            return "/boards/bookmark/"
        case .setNotification:
            return "/users/alarm"
        case .apply:
            /// 직관 신청 /enroll/{boardId}
            return "/enrolls/"
        case .cancelApply:
            return "/enrolls/cancel/"
        case .sendApply:
            return "/enrolls/request"
        case .sendApplyDetail:
            /// /enrolls/{boardId}/description
            return "/enrolls/"
        case .receivedApply:
            return "/enrolls/receive"
        case .receivedApplyAll:
            return "/enrolls/receive/all"
        case .receivedCount:
            return "/enrolls/new-count"
        case .acceptApply, .rejectApply:
            /// acceptApply = /enroll/{enrollId}/accept
            /// rejectApply = /enroll/{enrollId}/reject
            return "/enrolls/"
        case .chatList:
            return "/chat-rooms/list"
        case .chatUsers, .chatImage, .exitChat, .exportChatUser, .chatDetail, .chatRoomNotification:
            /// chat-rooms/{chatRoomId}/user-list
            /// chat-rooms/{chatRoomId}/image
            /// chat-rooms/{chatRoomId}
            /// chat-rooms/{chatRoomId}/users/{userId}
            /// chat-rooms/{chatRoomId}
            /// chat-rooms/{chatRoomId}/notification
            return "/chat-rooms/"
        case .chatMessage:
            /// chats/{chatRoomId}
            return "/chats/"
        case .loadMyInfo:
            return "/users/profile"
        case .editProfile:
            return "/users/profile"
        case .unreadMessage:
            return "/users/has-unread"
        // MARK: - 알림 관련
        case .notificationList:
            return "/notifications/receive"
        case .deleteNoti, .notification:
            return "/notifications/receive/"
        case .report:
            return "/reports"
        case .blockUserList:
            return "/users/block"
        case .blockUser, .unBlockUser:
            /// /users/block/{blockedUserId}
            return "/users/block/"
        case .inquiries:
            return "/inquiries"
        case .inquiryDetail:
            return "/inquiries/"
        case .noticesList:
            return "/notices/list"
        }
    }
    var apiName: String {
        switch self {
        case .login:
            return "로그인 API"
        case .logout:
            return "로그아웃 API"
        case .withdraw:
            return "탈퇴하기 API"
        case .signUp:
            return "회원가입 API"
        case .savePost:
            return "게시글 저장 API"
        case .tempPost:
            return "게시글 임시 저장 API"
        case .loadTempPost:
            return "임시 저장한 게시글 불러오기 API"
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
        case .sendApplyDetail:
            return "보낸 신청 상세 내용 조회 API"
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
        case .chatList:
            return "채팅방 리스트 조회 API"
        case .chatUsers:
            return "채팅방 참여 유저 조회 API"
        case .chatMessage:
            return "채팅방 이전 메시지 조회 API"
        case .chatImage:
            return "채팅방 이미지 수정 API"
        case .exitChat:
            return "채팅방 나가기 API"
        case .exportChatUser:
            return "채팅방 유저 내보내기 API"
        case .chatDetail:
            return "채팅방 1개 정보 조회 API"
        case .chatRoomNotification:
            return "채팅방 개별 알림 설정 API"
        case .loadMyInfo:
            return "내 정보 조회 API"
        case .editProfile:
            return "내 정보 수정 API"
        case .unreadMessage:
            return "안 읽은 알림 및 채팅 여부"
        case .notificationList:
            return "알림 리스트 조회 API"
        case .notification:
            return "알림 단일 조회 API"
        case .deleteNoti:
            return "받은 알림 삭제 API"
        case .report:
            return "유저 신고 API"
        case .blockUserList:
            return "차단 유저 리스트 조회 API"
        case .blockUser:
            return "유저 차단 API"
        case .unBlockUser:
            return "유저 차단 해제 API"
        case .inquiries:
            return "고객센터 문의 API"
        case .inquiryDetail:
            return "문의하기 답변 확인 API"
        case .noticesList:
            return "공지사항 리스트 조회 API"
        }
    }
    
    var requstType: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .logout, .withdraw:
            return .delete
        case .signUp:
            return .post
        case .savePost, .tempPost:
            return .post
        case .loadTempPost:
            return .get
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
        case .sendApply, .sendApplyDetail:
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
        // MARK: - 채팅 관련
        case .chatList, .chatDetail, .chatUsers, .chatMessage:
            return .get
        case .chatImage:
            return .patch
        case .chatRoomNotification:
            return .put
        case .exitChat, .exportChatUser:
            return .delete
        // MARK: - 유저 정보 관련
        case .loadMyInfo, .unreadMessage:
            return .get
        case .editProfile:
            return .patch
        // MARK: - 알림 관련
        case .notificationList, .notification:
            return .get
        case .deleteNoti:
            return .delete
            
        // MARK: - 차단 및 해제
        case .report, .blockUser:
            return .post
        case .blockUserList:
            return .get
        case .unBlockUser:
            return .delete
            
        // MARK: - 고객센터 관련
        case .inquiryDetail:
            return .get
        case .inquiries:
            return .post
        case .noticesList:
            return .get
        }
    }
}
