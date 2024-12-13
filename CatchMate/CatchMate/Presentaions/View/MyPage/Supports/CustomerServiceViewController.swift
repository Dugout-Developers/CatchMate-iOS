//
//  CustomerServiceViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 8/8/24.
//

import UIKit

final class CustomerServiceViewController: BaseViewController {
    override var useSnapKit: Bool {
        return true
    }
    override var buttonContainerExists: Bool {
        return true
    }
    private let navtitle: String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftTitle(navtitle)
        view.backgroundColor = .grayScale50
    }
    init(title: String) {
        self.navtitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
