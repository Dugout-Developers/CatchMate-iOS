//
//  ApplicationInfoViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 2/10/25.
//
import UIKit

final class ApplicationInfoViewController: BaseViewController {
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return false
    }
    private let tableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
