//
//  Date+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 7/4/24.
//

import UIKit

extension Date {
    func toString(format: String) -> String {
        return DateHelper.shared.toString(from: self, format: format)
    }
    
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
}
