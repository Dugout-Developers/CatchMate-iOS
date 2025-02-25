//
//  ChatListTableViewCell.swift
//  CatchMate
//
//  Created by 방유빈 on 6/18/24.
//

import UIKit
import PinLayout
import FlexLayout

final class ChatListTableViewCell: UITableViewCell {
    private var newChat: Bool = false
    private var newMessageCount: Int = 0
    let containerView = UIView()
    private let chatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .cmHeadLineTextColor
        return label
    }()
    
    private let lastChatLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .grayScale600
        return label
    }()
    
    private let peopleNumLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cmNonImportantTextColor
        return label
    }()

    private let lastChatDateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .cmNonImportantTextColor
        return label
    }()

    private let notiBadge: BadgeLabel = BadgeLabel()
    private let divider = UIView()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupUI()
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout(mode: .adjustHeight)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        containerView.pin.width(size.width)
        containerView.flex.layout(mode: .adjustHeight)
        return CGSize(width: size.width, height: containerView.frame.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postTitleLabel.text = ""
        peopleNumLabel.text = ""
        lastChatDateLabel.text = ""
        lastChatLabel.text = ""
        notiBadge.isHidden = false
        notiBadge.text = ""

        containerView.flex.layout(mode: .adjustHeight)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    func configData(chat: ChatListInfo) {
        let defaultImage = chat.postInfo.cheerTeam.getFillImage
        ImageLoadHelper.loadImage(chatImageView, pictureString: chat.chatImage, defaultImage: defaultImage)
        postTitleLabel.text = chat.postInfo.title
        newChat = chat.newChat
        lastChatLabel.text = (chat.lastMessage.isEmpty ? "채팅을 시작해보세요." : chat.lastMessage)
        newMessageCount = chat.notReadCount
        notiBadge.setBadgeCount(newMessageCount)
        notiBadge.isHidden = newMessageCount == 0 ? true : false
        lastChatDateLabel.text = chat.lastTimeAgo
        
        // Style
        postTitleLabel.applyStyle(textStyle: FontSystem.body01_medium)
        postTitleLabel.lineBreakMode = .byTruncatingTail
        lastChatLabel.applyStyle(textStyle: FontSystem.body02_medium)
        lastChatLabel.lineBreakMode = .byTruncatingTail
        notiBadge.applyStyle(textStyle: FontSystem.bedgeText)
        lastChatDateLabel.applyStyle(textStyle: FontSystem.caption01_medium)
        if newChat {
            peopleNumLabel.text = String(chat.currentPerson)
            peopleNumLabel.textColor = .cmNonImportantTextColor
        } else {
            peopleNumLabel.text = "New"
            peopleNumLabel.textColor = .cmPrimaryColor
        }
        peopleNumLabel.applyStyle(textStyle: FontSystem.caption01_medium)
        postTitleLabel.flex.markDirty()
        peopleNumLabel.flex.markDirty()
        lastChatDateLabel.flex.markDirty()
        lastChatLabel.flex.markDirty()
        notiBadge.flex.markDirty()
        containerView.flex.layout(mode: .adjustHeight)
    }
}

// MARK: - UI
extension ChatListTableViewCell {
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.flex.direction(.column).width(100%).paddingTop(16).define { flex in
            flex.addItem().direction(.row).width(100%).alignItems(.center).define { flex in
                flex.addItem(chatImageView).size(52)
                flex.addItem().direction(.column).grow(1).shrink(1).marginLeft(12).define { flex in
                    flex.addItem().direction(.row).define { flex in
                        flex.addItem().direction(.row).define { flex in
                            flex.addItem(postTitleLabel).shrink(1)
                            flex.addItem(peopleNumLabel).grow(1).marginLeft(5)
                        }.grow(1).shrink(1)
                        flex.addItem(lastChatDateLabel).marginLeft(35)
                    }.marginBottom(5)
                    flex.addItem().direction(.row).define { (flex) in
                        flex.addItem(lastChatLabel).grow(1).shrink(1)
                        
                        flex.addItem(notiBadge).alignSelf(.center).marginLeft(35)
                        
                    }
                }
            }.marginBottom(12)
            flex.addItem(divider).height(1).width(100%).backgroundColor(.cmStrokeColor)
        }
    }
}

class BadgeLabel: UILabel {
    let height: CGFloat = 20
    override var text: String? {
        didSet {
            self.applyStyle(textStyle: FontSystem.bedgeText)
            layoutIfNeeded()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        self.textAlignment = .center
        self.textColor = .white
        self.backgroundColor = .cmPrimaryColor
        self.layer.masksToBounds = true
    }

    /// 읽지 않은 메시지 개수 설정
    func setBadgeCount(_ count: Int) {
        let badgeText = count > 999 ? "999+" : "\(count)"
        self.text = badgeText
        if count < 10 {
            // 1~9: 원형 유지
            self.flex.width(height).height(height)
            self.layer.cornerRadius = height / 2
        } else {
            // 10 이상: 가로로 늘어난 타원
            self.sizeToFit()
            let width = max(self.frame.width + 14, height) // 최소 가로 길이 유지
            self.flex.width(width).height(height)
            self.layer.cornerRadius = height / 2
        }
        
        self.flex.markDirty()
    }
}

