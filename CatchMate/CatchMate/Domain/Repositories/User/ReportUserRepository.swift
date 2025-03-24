//
//  ReportUserRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 2/17/25.
//
import UIKit
import RxSwift

protocol ReportUserRepository {
    func reportUser(userId: Int, type: ReportType, content: String) -> Observable<Void>
}
