//
//  MypageMenu.swift
//  CatchMate
//
//  Created by 방유빈 on 8/1/24.
//

import UIKit
import RxSwift

enum MypageMenu: String {
    case notices = "공지사항"
    case customerService = "고객센터"
    case terms = "약관 및 정책"
    case info = "정보"

    case write = "작성한 글"
    case send = "보낸 신청"
    case receive = "받은 신청"
    
    case auth = "계정 정보"
    case noti = "알림 설정"
    case block = "차단 설정"
    
    static var supportMenus: [MypageMenu] {
        return [.notices, .customerService, .terms, .info]
    }
    
    static var myMenus: [MypageMenu] {
        return [.write, .send, .receive]
    }
    
    static var settingMenus: [MypageMenu] {
        return [.auth, .noti, .block]
    }
    
    func navigationVC(user: SimpleUser? = nil) -> Observable<UIViewController> {
        switch self {
        case .notices:
            return Observable.just(AnnouncementsViewController(reactor: AnnouncementsReactor()))
        case .terms:
            return Observable.just(TermViewController())
        case .customerService:
            guard let user = SetupInfoService.shared.getUsertInfo() else {
                return Observable.error(PresentationError.showToastMessage(message: "페이지를 불러오는데 실패했습니다."))
            }
            return Observable.just(CustomerServiceViewController(user: user))
        case .info:
            return Observable.just(ApplicationInfoViewController())
        case .write:
            guard let user = user else {
                return Observable.error(PresentationError.showErrorPage)
            }
            return Observable.just(OtherUserMyPageViewController(user: user, reactor: DIContainerService.shared.makeOtherUserPageReactor(user), reportReactor: ReportReactor()))
        case .send:
            return Observable.just(SendMateListViewController(reactor: DIContainerService.shared.makeSendMateReactor()))
        case .receive:
            return Observable.just(ReceiveMateListViewController(reactor: DIContainerService.shared.makeReciveMateReactor()))
        case .auth:
            return LoginUserDefaultsService.shared.getLoginData()
                .map { loginData in
                    let vc = AuthInfoSettingViewController(loginData: loginData)
                    return vc
                }
                .catch { _ in
                    return Observable.error(PresentationError.unauthorized)
                }
        case .noti:
            return Observable.just(NotificationSettingViewController(reactor: DIContainerService.shared.makeNotifiacationSettingReactor()))
        case .block:
            return Observable.just(BlockSettingViewController(reactor: BlockUserReactor()))
        }
    }
}

