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
    
    static func getMargin() -> CGFloat {
        return margin
    }
    static func getGutter() -> CGFloat {
        return gutter
    }
    static func getColumn() -> Int {
        return column
    }
    
    static func getColumnWidth(totalWidht:CGFloat) -> CGFloat {
        return (totalWidht - (margin * 2) - (gutter * CGFloat(column-1))) / CGFloat(column)
    }
    static func getGridSystem(totalWidht:CGFloat, startIndex: Int, columnCount: Int) -> (startPosition: CGFloat, length: CGFloat){
        let columnWidth = getColumnWidth(totalWidht: totalWidht)
        let startPosition = margin + (CGFloat((startIndex-1))*(gutter+columnWidth))
        let length = (CGFloat(columnCount) * columnWidth) + (CGFloat(columnCount-1) * gutter)
        
        return (startPosition, length)
    }
}

struct SubGridSystem {
    static private let margin: CGFloat = 24
    static private let gutter: CGFloat = 9
    static private let column: Int = 6
    
    static func getMargin() -> CGFloat {
        return margin
    }
    static func getGutter() -> CGFloat {
        return gutter
    }
    static func getColumn() -> Int {
        return column
    }
    
    static func getColumnWidth(totalWidht:CGFloat) -> CGFloat {
        return (totalWidht - (margin * 2) - (gutter * CGFloat(column-1))) / CGFloat(column)
    }
    static func getGridSystem(totalWidht:CGFloat, startIndex: Int, columnCount: Int) -> (startPosition: CGFloat, length: CGFloat){
        let columnWidth = getColumnWidth(totalWidht: totalWidht)
        let startPosition = margin + (CGFloat((startIndex-1))*(gutter+columnWidth))
        let length = (CGFloat(columnCount) * columnWidth) + (CGFloat(columnCount-1) * gutter)
        
        return (startPosition, length)
    }
}

struct ButtonGridSystem {
    static private let margin: CGFloat = 12
    static private let gutter: CGFloat = 9
    static private let column: Int = 5
    
    static func getMargin() -> CGFloat {
        return margin
    }
    static func getGutter() -> CGFloat {
        return gutter
    }
    static func getColumn() -> Int {
        return column
    }
    
    static func getColumnWidth(totalWidht:CGFloat) -> CGFloat {
        return (totalWidht - (margin * 2) - (gutter * CGFloat(column-1))) / CGFloat(column)
    }
    static func getGridSystem(totalWidht:CGFloat, startIndex: Int, columnCount: Int) -> (startPosition: CGFloat, length: CGFloat){
        let columnWidth = getColumnWidth(totalWidht: totalWidht)
        let startPosition = margin + (CGFloat((startIndex-1))*(gutter+columnWidth))
        let length = (CGFloat(columnCount) * columnWidth) + (CGFloat(columnCount-1) * gutter)
        
        return (startPosition, length)
    }
}
