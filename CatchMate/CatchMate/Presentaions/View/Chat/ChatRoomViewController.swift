//
//  ChatRoomViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 7/17/24.
//

import UIKit
import SnapKit

final class ChatRoomViewController: BaseViewController {
    // MARK: - 임시 뷰
    private let label: UILabel = {
        let label = UILabel()
        label.text = "채팅방 입니다. (개발중)"
        label.applyStyle(textStyle: FontSystem.pageTitle)
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
