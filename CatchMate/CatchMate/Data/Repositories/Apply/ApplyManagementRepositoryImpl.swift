//
//  ApplyManagementRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 10/1/24.
//

import UIKit
import RxSwift

final class ApplyManagementRepositoryImpl: ApplyManagementRepository {
    private let applyManagementDS: ApplyManagementDataSource
    init(applyManagementDS: ApplyManagementDataSource) {
        self.applyManagementDS = applyManagementDS
    }
    
    func acceptApply(enrollId: String) -> RxSwift.Observable<Bool> {
        return applyManagementDS.acceptApply(enrollId: enrollId)
    }
    
    func rejectApply(enrollId: String) -> RxSwift.Observable<Bool> {
        return applyManagementDS.rejectApply(enrollId: enrollId)
    }
}
