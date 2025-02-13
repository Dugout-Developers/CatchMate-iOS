//
//  UpdateChatImageRepositoryImpl.swift
//  CatchMate
//
//  Created by 방유빈 on 2/13/25.
//

import UIKit
import RxSwift

final class UpdateChatImageRepositoryImpl: UpdateChatImageRepository {
    private let updateImageDS: UpdateChatImageDataSource
    init(updateImageDS: UpdateChatImageDataSource) {
        self.updateImageDS = updateImageDS
    }
    func updateImage(chatId: Int, _ image: UIImage?) -> RxSwift.Observable<Bool> {
        return updateImageDS.updateChatImage(chatId: chatId, image: image)
    }
}
