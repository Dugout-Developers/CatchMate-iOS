//
//  MypageListCell.swift
//  CatchMate
//
//  Created by 방유빈 on 8/1/24.
//

import UIKit
import SnapKit
final class MypageListCell: UITableViewCell {
    private let containerView: UIView = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        setupUI()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configData(title: String) {
        titleLabel.text = title
        titleLabel.applyStyle(textStyle: FontSystem.body01_medium)
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.centerY.equalToSuperview()
        }
    }
}
