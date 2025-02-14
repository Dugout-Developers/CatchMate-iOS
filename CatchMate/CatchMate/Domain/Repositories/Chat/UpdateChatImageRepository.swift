//
//  UpdateChatImageRepository.swift
//  CatchMate
//
//  Created by 방유빈 on 2/13/25.
//

import UIKit
import RxSwift

protocol UpdateChatImageRepository {
    func updateImage(chatId: Int, _ image: UIImage?) -> Observable<Bool>
}
