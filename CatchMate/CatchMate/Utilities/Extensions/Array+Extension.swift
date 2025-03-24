//
//  Array+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 3/15/25.
//

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
