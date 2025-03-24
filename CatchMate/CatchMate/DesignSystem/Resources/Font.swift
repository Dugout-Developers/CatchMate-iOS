//
//  Font.swift
//  CatchMate
//
//  Created by 방유빈 on 7/3/24.
//

import UIKit
extension UIFont {
    /// 28 - semibold
    static let headline01_semiBold = FontUtility.loadPretendardFont(size: 28, weight: .semibold)
    /// 28 - medium
    static let headline01_medium = FontUtility.loadPretendardFont(size: 28, weight: .medium)
    /// 28 - regular
    static let headline01_reguler = FontUtility.loadPretendardFont(size: 28, weight: .regular)
    /// 24 - semibold
    static let headline02_semiBold = FontUtility.loadPretendardFont(size: 24, weight: .semibold)
    /// 24 - medium
    static let headline02_medium = FontUtility.loadPretendardFont(size: 24, weight: .medium)
    /// 24 - regular
    static let headline02_reguler = FontUtility.loadPretendardFont(size: 24, weight: .regular)
    /// 20 - semibold
    static let headline03_semiBold = FontUtility.loadPretendardFont(size: 20, weight: .semibold)
    /// 20 - medium
    static let headline03_medium = FontUtility.loadPretendardFont(size: 20, weight: .medium)
    /// 20 - regular
    static let headline03_reguler = FontUtility.loadPretendardFont(size: 20, weight: .regular)
    /// 16 - semibold
    static let body01_semiBold = FontUtility.loadPretendardFont(size: 16, weight: .semibold)
    /// 16 - medium
    static let body01_medium = FontUtility.loadPretendardFont(size: 16, weight: .medium)
    /// 16 - regular
    static let body01_reguler = FontUtility.loadPretendardFont(size: 16, weight: .regular)
    /// 14 - semibold
    static let body02_semiBold = FontUtility.loadPretendardFont(size: 14, weight: .semibold)
    /// 14 - medium
    static let body02_medium = FontUtility.loadPretendardFont(size: 14, weight: .medium)
    /// 14 - regular
    static let body02_reguler = FontUtility.loadPretendardFont(size: 14, weight: .regular)
    /// 12 - semibold
    static let body03_semiBold = FontUtility.loadPretendardFont(size: 12, weight: .semibold)
    /// 12 - medium
    static let body03_medium = FontUtility.loadPretendardFont(size: 12, weight: .medium)
    /// 12 - regular
    static let body03_reguler = FontUtility.loadPretendardFont(size: 12, weight: .regular)
    /// 11 - semibold
    static let caption01_semiBold = FontUtility.loadPretendardFont(size: 11, weight: .semibold)
    /// 11 - medium
    static let caption01_medium = FontUtility.loadPretendardFont(size: 11, weight: .medium)
    /// 11 - regular
    static let caption01_reguler = FontUtility.loadPretendardFont(size: 11, weight: .regular)
    
    /// 10 - medium
    static let bedgeText = FontUtility.loadPretendardFont(size: 10, weight: .medium)
}


final class FontSystem {
    // MARK: - 전체 폰트 스타일
    /// size/lineHeight/kern = 28/36/-0.01
    static let headline01_semiBold = TextStyle(font: .headline01_semiBold, kern: -0.01, lineHeight: 36)
    /// size/lineHeight/kern = 28/36/-0.01
    static let headline01_medium = TextStyle(font: .headline01_medium, kern: -0.01, lineHeight: 36)
    /// size/lineHeight/kern = 28/36/-0.01
    static let headline01_reguler = TextStyle(font: .headline01_reguler, kern: -0.01, lineHeight: 36)
    
    /// size/lineHeight/kern = 24/31/0
    static let headline02_semiBold = TextStyle(font: .headline02_semiBold, kern: 0, lineHeight: 31)
    /// size/lineHeight/kern = 24/31/0
    static let headline02_medium = TextStyle(font: .headline02_medium, kern: 0, lineHeight: 31)
    /// size/lineHeight/kern = 24/31/0
    static let headline02_reguler = TextStyle(font: .headline02_reguler, kern: 0, lineHeight: 31)
    
    /// size/lineHeight/kern = 20/26/0
    static let headline03_semiBold = TextStyle(font: .headline03_semiBold, kern: 0, lineHeight: 26)
    /// size/lineHeight/kern = 20/26/0
    static let headline03_medium = TextStyle(font: .headline03_medium, kern: 0, lineHeight: 26)
    /// size/lineHeight/kern = 20/26/0
    static let headline03_reguler = TextStyle(font: .headline03_reguler, kern: 0, lineHeight: 26)
    
    /// size/lineHeight/kern = 16/21/0
    static let body01_semiBold = TextStyle(font: .body01_semiBold, kern: 0, lineHeight: 21)
    /// size/lineHeight/kern = 16/21/0
    static let body01_medium = TextStyle(font: .body01_medium, kern: 0, lineHeight: 21)
    /// size/lineHeight/kern = 16/21/0
    static let body01_reguler = TextStyle(font: .body01_reguler, kern: 0, lineHeight: 21)
    
    /// size/lineHeight/kern = 14/18/0
    static let body02_semiBold = TextStyle(font: .body02_semiBold, kern: 0, lineHeight: 18)
    /// size/lineHeight/kern = 14/18/0
    static let body02_medium = TextStyle(font: .body02_medium, kern: 0, lineHeight: 18)
    /// size/lineHeight/kern = 14/18/0
    static let body02_reguler = TextStyle(font: .body02_reguler, kern: 0, lineHeight: 18)
    
    /// size/lineHeight/kern = 12/16/0
    static let body03_semiBold = TextStyle(font: .body03_semiBold, kern: 0, lineHeight: 16)
    /// size/lineHeight/kern = 12/16/0
    static let body03_medium = TextStyle(font: .body03_medium, kern: 0, lineHeight: 16)
    /// size/lineHeight/kern = 12/16/0
    static let body03_reguler = TextStyle(font: .body03_reguler, kern: 0, lineHeight: 16)
    
    /// size/lineHeight/kern = 11/15/0
    static let caption01_semiBold = TextStyle(font: .caption01_semiBold, kern: 0, lineHeight: 15)
    /// size/lineHeight/kern = 11/15/0
    static let caption01_medium = TextStyle(font: .caption01_medium, kern: 0, lineHeight: 15)
    /// size/lineHeight/kern = 11/15/0
    static let caption01_reguler = TextStyle(font: .caption01_reguler, kern: 0, lineHeight: 15)
    /// size/lineHeight/kern = 10/nil/0
    static let bedgeText = TextStyle(font: .bedgeText)
    
    // MARK: - Semantic 폰트 스타일
    /// headline03_medium (20)
    static let header = headline03_medium
    /// headline01_reguler (28)
    static let highlight = headline01_reguler
    /// headline02_semiBold (24)
    static let pageTitle = headline02_semiBold
    /// body01_medium (16)
    static let bodyTitle = body01_medium
    /// body02_medium (14)
    static let contents = body02_medium
    /// caption01_medium (11)
    static let chip = caption01_medium
}
