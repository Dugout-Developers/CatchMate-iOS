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
    private let notiBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = .cmPrimaryColor
        view.clipsToBounds = true
        return view
    }()
    private let notiBadge: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    
    
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
        notiBadgeView.isHidden = false
        notiBadge.text = ""

        containerView.flex.layout(mode: .adjustHeight)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    func configData(chat: Chat) {
        chatImageView.image = chat.post.writer.favGudan.getFillImage
        postTitleLabel.text = chat.post.title
        newChat = chat.enterTime.isSameDay(as: Date())
        lastChatLabel.text = newChat ? "채팅을 시작해보세요." : (chat.message.last?.text ?? "채팅을 시작해보세요.")
        newMessageCount = chat.notRead
        notiBadge.text = String(newMessageCount)
        notiBadgeView.isHidden = newMessageCount == 0 ? true : false
        lastChatDateLabel.text = chat.message.last?.date.timeAgoDisplay() ?? chat.enterTime.timeAgoDisplay()
        
        // Style
        postTitleLabel.applyStyle(textStyle: FontSystem.body01_medium)
        postTitleLabel.lineBreakMode = .byTruncatingTail
        lastChatLabel.applyStyle(textStyle: FontSystem.body02_medium)
        lastChatLabel.lineBreakMode = .byTruncatingTail
        notiBadge.applyStyle(textStyle: FontSystem.bedgeText)
        lastChatDateLabel.applyStyle(textStyle: FontSystem.caption01_medium)
        if newChat {
            peopleNumLabel.text = String(chat.post.currentPerson)
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
        notiBadgeView.flex.markDirty()
        containerView.flex.layout(mode: .adjustHeight)
    }
}

// MARK: - UI
extension ChatListTableViewCell {
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.flex.direction(.row).width(100%).paddingTop(16).paddingBottom(12).alignItems(.center).define { flex in
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
                    flex.addItem(notiBadgeView).size(18).cornerRadius(9).marginLeft(35).alignItems(.center).justifyContent(.center).define { flex in
                        flex.addItem(notiBadge).alignSelf(.center)
                    }
                }
            }
        }
    }
}



