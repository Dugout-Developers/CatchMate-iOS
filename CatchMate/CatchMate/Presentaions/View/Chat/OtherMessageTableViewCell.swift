//
//  OtherMessageTableViewCell.swift
//  CatchMate
//
//  Created by 방유빈 on 7/25/24.
//

import UIKit
import SnapKit

final class OtherMessageTableViewCell: UITableViewCell {
    private var isHiddenTime: Bool = false
    private var isHiddenProfile: Bool = false
    private let containerView = UIView()
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayScale600
        return label
    }()
    private let messageLabel: MessageBoxLabel = {
        let label = MessageBoxLabel()
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.clipsToBounds = true
        label.layer.masksToBounds = true
        label.textColor = .cmHeadLineTextColor
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
        nickNameLabel.text = ""
        profileImageView.image = nil
        isHiddenTime = false
        isHiddenProfile = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        messageLabel.setCornerRadius(8, forCorners: [.topRight, .bottomLeft, .bottomRight])
    }
    
    func configData(_ chat: ChatMessage, isHiddenTime: Bool, isHiddenProfile: Bool) {
        ProfileImageHelper.loadImage(profileImageView, pictureString: chat.imageUrl)
        nickNameLabel.text = chat.nickName
        nickNameLabel.applyStyle(textStyle: FontSystem.body03_semiBold)
        let dateString = chat.time.toString(format: "a h:mm")
        timeLabel.text = dateString
        timeLabel.applyStyle(textStyle: FontSystem.caption01_medium)
        messageLabel.text = chat.message
        messageLabel.applyStyle(textStyle: FontSystem.body02_medium)
        self.isHiddenTime = isHiddenTime
        self.isHiddenProfile = isHiddenProfile
        updateUI()
        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()
    }
    
    private func setupUI() {
        let maxWidth = MainGridSystem.getGridSystem(totalWidht: Screen.width, startIndex: 2, columnCount: 5).length
        contentView.addSubview(containerView)
        containerView.addSubviews(views: [profileImageView, nickNameLabel, messageLabel, timeLabel])
        containerView.addSubview(messageLabel)
        
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(MainGridSystem.getMargin())
            make.width.equalTo(maxWidth)
            make.top.bottom.equalToSuperview().inset(4)
        }
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.leading.top.equalToSuperview()
        }
        nickNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView).offset(-4)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
        }
        messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(nickNameLabel)
            make.top.equalTo(nickNameLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
        messageLabel.setContentHuggingPriority(.required, for: .horizontal)
        messageLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        messageLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(messageLabel.snp.trailing).offset(8)
            make.trailing.bottom.equalToSuperview()
        }

    }
    
    private func updateUI() {
        if isHiddenProfile {
            profileImageView.image = nil
            nickNameLabel.snp.remakeConstraints { make in
                make.leading.equalTo(profileImageView.snp.trailing).offset(8)
                make.top.equalTo(profileImageView).offset(-4)
                make.size.equalTo(0)
            }
        } else {
            profileImageView.snp.remakeConstraints { make in
                make.size.equalTo(40)
                make.leading.top.equalToSuperview()
            }
            nickNameLabel.snp.remakeConstraints { make in
                make.top.equalTo(profileImageView).offset(-4)
                make.leading.equalTo(profileImageView.snp.trailing).offset(8)
                make.trailing.equalToSuperview()
            }
        }
        
        if isHiddenTime {
            timeLabel.snp.remakeConstraints { make in
                make.leading.equalTo(messageLabel.snp.trailing)
                make.bottom.trailing.equalToSuperview()
                make.size.equalTo(1)
            }
        }else {
            timeLabel.snp.remakeConstraints { make in
                make.leading.equalTo(messageLabel.snp.trailing).offset(8)
                make.bottom.equalToSuperview()
                make.trailing.equalToSuperview()
            }
        }
    }
}
