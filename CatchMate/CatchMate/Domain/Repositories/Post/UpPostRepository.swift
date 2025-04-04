//
//  UpPostRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 1/8/25.
//

import UIKit
import RxSwift

protocol UpPostRepository {
    func upPost(_ postId: String) -> Observable<(result: Bool, message: String?)>
}
