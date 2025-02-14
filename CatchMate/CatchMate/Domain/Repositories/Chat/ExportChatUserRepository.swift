//
//  ExportChatUserRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 2/14/25.
//

import UIKit
import RxSwift

protocol ExportChatUserRepository {
    func exportUser(chatId: Int, userId: Int) -> Observable<Void>
}
