//
//  LoadNoticeListRepsitory.swift
//  CatchMate
//
//  Created by 방유빈 on 2/26/25.
//

import RxSwift

protocol LoadNoticeListRepsitory {
    func loadNotices(_ page: Int) -> Observable<(notices: [Announcement], isLast: Bool)>
}
