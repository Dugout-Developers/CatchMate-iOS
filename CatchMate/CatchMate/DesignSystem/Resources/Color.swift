//
//  Color.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit

extension UIColor {
    // MARK: - Semantic Color
    static let cmBackgroundColor = UIColor(hex: "#F7F8FA")
    static let cmPrimaryColor = brandColor500
    
    static let cmTextGray = UIColor(hex: "#414141")
    static let cmHeadLineTextColor = grayScale800
    static let cmBodyTextColor = grayScale700
    static let cmSubTextColor = grayScale600
    static let cmNonImportantTextColor = grayScale500
    
    static let cmDisabledButtonColor = brandColor50
    static let cmEnabledButtonColor = brandColor500
    static let cmPressedButtonColor = brandColor600
    static let cmWeakButtonColor = brandColor100
    
    static let cmBorderColor = grayScale200
    static let cmStrokeColor = grayScale100
    
    // MARK: - SystemColor
    static let cmSystemBule = UIColor(hex: "#3182F6")
    static let cmSystemRed = UIColor(hex: "#EE5147")
    
    // MARK: - BrandColor
    static let brandColor50 = UIColor(hex: "#FFDFDF")
    static let brandColor100 = UIColor(hex: "#FEBFBF")
    static let brandColor200 = UIColor(hex: "#FE9E9E")
    static let brandColor300 = UIColor(hex: "#FE8F8F")
    static let brandColor400 = UIColor(hex: "#FD7E7E")
    static let brandColor500 = UIColor(hex: "#FD5E5E")
    static let brandColor600 = UIColor(hex: "#DB5456")
    static let brandColor700 = UIColor(hex: "#BA4B4D")
    static let brandColor800 = UIColor(hex: "#994245")
    static let brandColor900 = UIColor(hex: "#77383C")
    
    // MARK: - GrayScale
    static let grayScale50 = UIColor(hex: "#FCFAFA")
    static let grayScale100 = UIColor(hex: "#F5F2F2")
    static let grayScale200 = UIColor(hex: "#EEE9E9")
    static let grayScale300 = UIColor(hex: "#D0CCCE")
    static let grayScale400 = UIColor(hex: "#B2AFB2")
    static let grayScale500 = UIColor(hex: "#949297")
    static let grayScale600 = UIColor(hex: "#76747B")
    static let grayScale700 = UIColor(hex: "#595860")
    static let grayScale800 = UIColor(hex: "#3B3B45")
    static let grayScale900 = UIColor(hex: "#1E1E25")
    
    // MARK: - Opacity Color
    static let opacity100 = UIColor(hex: "#000021", opacity: 0.05)
    static let opacity300 = UIColor(hex: "#000021", opacity: 0.15)
    static let opacity400 = UIColor(hex: "#595860", opacity: 0.4)
    static let opacity600 = UIColor(hex: "#595860", opacity: 0.8)
}

