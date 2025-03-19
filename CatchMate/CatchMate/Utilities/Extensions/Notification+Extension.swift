//
//  Notification+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 2/24/25.
//

import Foundation

extension Notification.Name {
    static let notificationStatusChanged = Notification.Name("notificationStatusChanged")
    static let reloadUnreadMessageState = Notification.Name("reloadUnreadMessageState")
    static let loadMissedMessage = Notification.Name("loadMissedMessage")
    static let submitContact = Notification.Name("submitContact")
}
