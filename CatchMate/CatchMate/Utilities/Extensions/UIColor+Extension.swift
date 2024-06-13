//
//  UIColor+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit

extension UIColor {
    /// #FFFFFF와 같이 16진수 hexString color를 쓸 수 있음.
    convenience init(hex: String, opacity: Double = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: opacity)
    }
}
