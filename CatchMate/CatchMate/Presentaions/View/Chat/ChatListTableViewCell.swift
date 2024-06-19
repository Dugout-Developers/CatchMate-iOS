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
    private var newMessageCount: Int = 2
    
    private let containerView = UIView()
    private let chatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "profile")
        return imageView
    }()
    
    private let chatInfoContainerView = UIView()
    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "카리나 시구 보러 같이 가실 분"
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16)
        label.textColor = .cmTextGray
        return label
    }()
    
    private let lastChatLabel: UILabel = {
        let label = UILabel()
        label.text = "저 롯데팬은 아니고 카리나만 보러 가고 싶은데 혹시 괜찮으실까요?"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(hex: "#9F9F9F")
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let subInfoContainerView = UIView()
    private let peopleNumLabel: UILabel = {
        let label = UILabel()
        label.text = "3명"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(hex: "#9F9F9F")
        return label
    }()
    private let dotView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor(hex: "#9F9F9F")
        view.layer.cornerRadius = 1
        return view
    }()
    private let lastChatDateLabel: UILabel = {
        let label = UILabel()
        label.text = "59분전"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(hex: "#9F9F9F")
        return label
    }()
    private let notiBadge: UILabel = {
        let label = UILabel()
        label.text = "2"
        label.font = .systemFont(ofSize: 10)
        label.textColor = .white
        label.backgroundColor = .cmPrimaryColor
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupUI()
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        containerView.pin.width(size.width)
        containerView.flex.layout(mode: .adjustHeight)
        return CGSize(width: size.width, height: containerView.frame.height)
    }
}

// MARK: - UI
extension ChatListTableViewCell {
    private func setupUI() {
        addSubview(containerView)
        
        containerView.flex.direction(.row).paddingVertical(16).justifyContent(.spaceBetween).alignItems(.center).define { flex in
            flex.addItem(chatImageView).size(64).marginRight(10)
            flex.addItem(chatInfoContainerView).direction(.column).justifyContent(.start).alignItems(.start).grow(1).shrink(1).define { flex in
                flex.addItem(postTitleLabel)
                flex.addItem(lastChatLabel).marginTop(4).marginBottom(12)
                flex.addItem(subInfoContainerView).direction(.row).justifyContent(.start).alignItems(.center).define { flex in
                    flex.addItem(peopleNumLabel)
                    flex.addItem(dotView).size(2).marginHorizontal(4)
                    flex.addItem(lastChatDateLabel)
                }
            }
            if newMessageCount > 0 {
                flex.addItem(notiBadge).size(18).cornerRadius(9).marginLeft(10)
            }
        }
    }
}


