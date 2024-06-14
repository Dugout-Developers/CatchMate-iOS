//
//  UITableView+Extension.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit

protocol Reusable: AnyObject {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: Reusable { }


extension UITableView {
    func cellForRow<T: UITableViewCell>(atIndexPath indexPath: IndexPath) -> T {
        guard
            let cell = cellForRow(at: indexPath) as? T
        else {
            fatalError("Could not cellForItemAt at \(T.reuseIdentifier) cell")
        }
        return cell
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath, cellType: T.Type = T.self) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Fail to dequeue: \(T.reuseIdentifier) cell")
        }
        return cell
    }
    
    func register<T>(cell: T.Type) where T: UITableViewCell {
        register(cell, forCellReuseIdentifier: cell.reuseIdentifier)
    }
}
