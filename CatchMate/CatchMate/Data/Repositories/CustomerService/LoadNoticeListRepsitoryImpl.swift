//
//  LoadNoticeListRepsitoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 2/26/25.
//

import RxSwift

final class LoadNoticeListRepsitoryImpl: LoadNoticeListRepsitory {
    private let loadNoticeDS: LoadNoticeListDataSource
    init(loadNoticeDS: LoadNoticeListDataSource) {
        self.loadNoticeDS = loadNoticeDS
    }
    func loadNotices(_ page: Int) -> RxSwift.Observable<(notices: [Announcement], isLast: Bool)> {
        return loadNoticeDS.loadNotices(page)
            .map { dto in
                var mappingResult = [Announcement]()
                for notice in dto.noticeInfoList {
                    guard let date = DateHelper.shared.convertISOStringToDate(notice.updatedAt) else {
                        LoggerService.shared.log("공지사항 업데이트 날짜 변환 실패")
                        continue
                    }
                    mappingResult.append(Announcement(id: notice.noticeId, title: notice.title, writeDate: date, contents: notice.content))
                }
                return (mappingResult, dto.isLast)
            }
    }
    
    
}
