//
//  MyPageViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/14/24.
//

import UIKit

class MyPageViewController: BaseViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLeftTitle("내정보")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cmBackgroundColor
//        setupLeftTitle("내정보")
    }
}
