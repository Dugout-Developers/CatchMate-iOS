//
//  ApplyManagementRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 10/1/24.
//

import UIKit
import RxSwift

protocol ApplyManagementRepository {
    func acceptApply(enrollId: String) -> Observable<Bool>
    func rejectApply(enrollId: String) -> Observable<Bool>
}
