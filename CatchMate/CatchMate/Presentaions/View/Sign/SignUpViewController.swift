//
//  SignUpViewController.swift
//  CatchMate
//
//  Created by 방유빈 on 6/24/24.
//

import UIKit

final class SignUpViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = "딱맞는 직관 친구를 구하기 위해\n정보를 입력해주세요."
        label.adjustsFontForContentSizeCategory = true
        label.font = .systemFont(ofSize: 28)
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    private let requiredMark: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "requiredMark")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    private func setupView() {
        view.backgroundColor = .white
    }
}
