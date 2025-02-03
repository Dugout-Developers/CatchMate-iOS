//
//  MyMessageTableViewCell.swift
//  CatchMate
//
//  Created by 방유빈 on 7/24/24.
//

import UIKit
import SnapKit

final class MyMessageTableViewCell: UITableViewCell {
    private let containerView = UIView()
    private let messageLabel: MessageBoxLabel = {
        let label = MessageBoxLabel()
        label.numberOfLines = 0
        label.backgroundColor = .cmPrimaryColor
        label.clipsToBounds = true
        label.layer.masksToBounds = true
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = ""
        timeLabel.text = ""
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        messageLabel.setCornerRadius(8, forCorners: [.topLeft, .bottomLeft, .bottomRight])
    }
    
    func configData(_ chat: ChatMessage) {
        let dateString = chat.time.toString(format: "a h:mm")
        timeLabel.text = dateString
        timeLabel.applyStyle(textStyle: FontSystem.caption01_medium)
        messageLabel.text = chat.message
        messageLabel.applyStyle(textStyle: FontSystem.body02_medium)
        timeLabel.textAlignment = .right
    }
    
    private func setupUI() {
        let maxWidth = (UIScreen.main.bounds.width - (2 * MainGridSystem.getMargin())) * (5/6)
        contentView.addSubview(containerView)
        containerView.addSubviews(views: [messageLabel, timeLabel])

        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.trailing.equalToSuperview().inset(MainGridSystem.getMargin())
            make.width.lessThanOrEqualTo(maxWidth).priority(.init(999))
            make.centerY.equalToSuperview()
        }
        messageLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.greaterThanOrEqualTo(40).priority(.medium)
        }
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(messageLabel.snp.leading).offset(-8)
            make.bottom.equalTo(messageLabel.snp.bottom)
            make.leading.equalToSuperview()
        }

        // 우선순위 설정
        timeLabel.setContentCompressionResistancePriority(.init(998), for: .horizontal)
        timeLabel.setContentHuggingPriority(.init(998), for: .horizontal)
        messageLabel.setContentCompressionResistancePriority(.init(997), for: .horizontal)
        messageLabel.setContentHuggingPriority(.init(997), for: .horizontal)
        
    }

}
