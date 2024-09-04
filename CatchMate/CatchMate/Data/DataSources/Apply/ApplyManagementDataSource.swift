//
//  ApplyManagementDataSource.swift
//  CatchMate
//
//  Created by 방유빈 on 9/3/24.
//

import UIKit
import RxSwift
import RxAlamofire
import Alamofire

protocol ApplyManagementDataSource {
    func acceptApply(enrollId: String) -> Observable<Bool>
    func rejectApply(enrollId: String) -> Observable<Bool>
}

