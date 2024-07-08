//
//  GridSystem.swift
//  CatchMate
//
//  Created by 방유빈 on 7/9/24.
//

import Foundation

struct MainGridSystem {
    static private let margin: CGFloat = 18
    static private let gutter: CGFloat = 9
    static private let column: Int = 6
    
    static func getGridSystem(totalWidht:CGFloat, startIndex: Int, columnCount: Int) -> (startPosition: CGFloat, length: CGFloat){
        let columnWidth = (totalWidht - (margin * 2) - (gutter * CGFloat(column-1))) / CGFloat(column)
        let startPosition = margin + (CGFloat((startIndex-1))*(gutter+columnWidth))
        let length = (CGFloat(columnCount) * columnWidth) + (CGFloat(columnCount-1) * gutter)
        
        return (startPosition, length)
    }
}

struct SubGridSystem {
    static private let margin: CGFloat = 24
    static private let gutter: CGFloat = 9
    static private let column: Int = 6
    
    static func getGridSystem(totalWidht:CGFloat, startIndex: Int, columnCount: Int) -> (startPosition: CGFloat, length: CGFloat){
        let columnWidth = (totalWidht - (margin * 2) - (gutter * CGFloat(column-1))) / CGFloat(column)
        let startPosition = margin + (CGFloat((startIndex-1))*(gutter+columnWidth))
        let length = (CGFloat(columnCount) * columnWidth) + (CGFloat(columnCount-1) * gutter)
        
        return (startPosition, length)
    }
}

