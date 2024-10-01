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
    
    static var supportMenus: [MypageMenu] {
        return [.notices, .customerService, .terms, .info]
    }
    
    static var myMenus: [MypageMenu] {
        return [.write, .send, .receive]
    }
    
    static var settingMenus: [MypageMenu] {
        return [.auth, .noti]
    }
    
    func navigationVC(user: SimpleUser? = nil) -> Observable<UIViewController> {
        switch self {
        case .notices:
            return Observable.just(AnnouncementsViewController(reactor: AnnouncementsReactor()))
        case .customerService, .terms, .info:
            return Observable.just(CustomerServiceViewController(title: self.rawValue))
        case .write:
            guard let user = user else {
                return Observable.error(PresentationError.showErrorPage(message: "요청을 처리할 수 없습니다. 다시 시도해주세요."))
            }
            return Observable.just(OtherUserMyPageViewController(user: user, reactor: DIContainerService.shared.makeOtherUserPageReactor(user)))
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
                    return Observable.error(PresentationError.unauthorized(message: "계정 정보를 찾을 수 없습니다. 다시 로그인해주세요."))
                }
        case .noti:
            return Observable.just(NotificationSettingViewController(reactor: NotificationSettingReactor()))
        }
    }
}

